// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IPXBridge} from "./interfaces/IPXBridge.sol";
import {ICrossDomainMessenger} from "./interfaces/ICrossDomainMessenger.sol";

contract PXBridgeL1 is IPXBridge, Ownable {
    ICrossDomainMessenger immutable MESSENGER;
    address immutable PX;

    address L2_TARGET; // target contract on L2

    constructor(address messenger_, address px_) {
        MESSENGER = ICrossDomainMessenger(messenger_);
        PX = px_;
    }

    function bridge(uint256 tokenId) external override {
        require(msg.sender == PX, "PXBridge: invalid sender");
        require(L2_TARGET != address(0), "PXBridge: target not set");

        emit Bridge(tokenId);
        MESSENGER.sendMessage(L2_TARGET, abi.encodeCall(IPXBridge.bridge, tokenId), 100_000); // TODO: estimate gas
    }

    function setTarget(address target) external onlyOwner {
        L2_TARGET = target;
    }
}

contract PXBridgeL2 is IPXBridge, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Callback {
        address target;
        bytes4 selector;
    }

    ICrossDomainMessenger immutable MESSENGER;
    address L1_SOURCE; // source contract on L1

    EnumerableSet.UintSet bridgedTokens;
    Callback callback;

    constructor(address messenger_) {
        MESSENGER = ICrossDomainMessenger(messenger_);
    }

    function bridge(uint256 tokenId) external override {
        require(
            msg.sender == address(MESSENGER) && MESSENGER.xDomainMessageSender() == L1_SOURCE,
            "PXBridge: invalid sender"
        );

        if (bridgedTokens.add(tokenId)) {
            emit Bridge(tokenId);

            if (callback.target != address(0)) {
                (bool success,) = callback.target.call(abi.encodeWithSelector(callback.selector, tokenId));
                require(success, "PXBridge: callback failed");
            }
        }
    }

    function contains(uint256 tokenId) external view returns (bool) {
        return bridgedTokens.contains(tokenId);
    }

    function length() external view returns (uint256) {
        return bridgedTokens.length();
    }

    function at(uint256 index) external view returns (uint256) {
        return bridgedTokens.at(index);
    }

    function values() external view returns (uint256[] memory) {
        return bridgedTokens.values();
    }

    function setSource(address source) external onlyOwner {
        L1_SOURCE = source;
    }

    function setCallback(address target, bytes4 selector) external onlyOwner {
        callback = Callback(target, selector);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
    function sendMessage(address _target, bytes calldata _message, uint32 _gasLimit) external;
}

interface IPXBridge {
    event Bridge(uint256 indexed tokenId);

    function bridge(uint256 tokenId) external;
}

contract PXBridgeL1 is IPXBridge {
    ICrossDomainMessenger immutable MESSENGER;
    address immutable PX;

    address immutable L2_TARGET; // target contract on L2

    constructor(address messenger_, address target_, address px_) {
        MESSENGER = ICrossDomainMessenger(messenger_);
        L2_TARGET = target_;
        PX = px_;
    }

    function bridge(uint256 tokenId) external override {
        require(msg.sender == PX, "PXBridge: invalid sender");

        emit Bridge(tokenId);
        MESSENGER.sendMessage(L2_TARGET, abi.encodeCall(IPXBridge.bridge, tokenId), 100_000); // TODO: estimate gas
    }
}

contract PXBridgeL2 is IPXBridge {
    using EnumerableSet for EnumerableSet.UintSet;

    ICrossDomainMessenger immutable MESSENGER;
    address immutable L1_SOURCE; // source contract on L1

    EnumerableSet.UintSet bridgedTokens;

    constructor(address messenger_, address source_) {
        MESSENGER = ICrossDomainMessenger(messenger_);
        L1_SOURCE = source_;
    }

    function bridge(uint256 tokenId) external override {
        require(
            msg.sender == address(MESSENGER) && MESSENGER.xDomainMessageSender() == L1_SOURCE,
            "PXBridge: invalid sender"
        );

        if (bridgedTokens.add(tokenId)) {
            emit Bridge(tokenId);
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
}

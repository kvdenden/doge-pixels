// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
    function sendMessage(address _target, bytes calldata _message, uint32 _gasLimit) external;
}

interface IPXBridge {
    event Bridge(uint256 indexed tokenId);

    function bridge(uint256 tokenId) external;
}

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

        emit Bridge(tokenId);
        MESSENGER.sendMessage(L2_TARGET, abi.encodeCall(IPXBridge.bridge, tokenId), 100_000); // TODO: estimate gas
    }

    function setTarget(address target) external onlyOwner {
        L2_TARGET = target;
    }
}

contract PXBridgeL2 is IPXBridge, Ownable {
    ICrossDomainMessenger immutable MESSENGER;
    address L1_SOURCE; // source contract on L1

    constructor(address messenger_) {
        MESSENGER = ICrossDomainMessenger(messenger_);
    }

    function bridge(uint256 tokenId) external override {
        require(
            msg.sender == address(MESSENGER) && MESSENGER.xDomainMessageSender() == L1_SOURCE,
            "PXBridge: invalid sender"
        );

        emit Bridge(tokenId); // TODO: make token available on L2
    }

    function setSource(address source) external onlyOwner {
        L1_SOURCE = source;
    }
}

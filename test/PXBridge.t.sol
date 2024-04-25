// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";

import {PXBridgeL2} from "../src/PXBridge.sol";
import {IPXBridge} from "../src/interfaces/IPXBridge.sol";
import {IBridgedPX} from "../src/interfaces/IBridgedPX.sol";
import {ICrossDomainMessenger} from "../src/interfaces/ICrossDomainMessenger.sol";

contract MockMessenger is ICrossDomainMessenger {
    address _sender;

    function xDomainMessageSender() external view override returns (address) {
        return _sender;
    }

    function setXDomainMessageSender(address sender) external {
        _sender = sender;
    }

    function sendMessage(address target, bytes calldata message, uint32 gasLimit) external override {
        (bool success,) = target.call{gas: gasLimit}(message);
        require(success, "MockMessenger: call failed");
    }
}

contract MockTarget {
    mapping(uint256 => bool) _bridged;

    function bridge(uint256 tokenId) external {
        _bridged[tokenId] = true;
    }

    function bridged(uint256 tokenId) external view returns (bool) {
        return _bridged[tokenId];
    }
}

contract PXBridgeTest is Test {
    MockMessenger messenger;
    PXBridgeL2 bridge;

    function setUp() public {
        address source = vm.addr(1337);

        messenger = new MockMessenger();
        messenger.setXDomainMessageSender(source);

        bridge = new PXBridgeL2(address(messenger));
        bridge.setSource(source);
    }

    function testBridge() public {
        uint256 tokenId = 1337;

        vm.expectEmit();
        emit IPXBridge.Bridge(tokenId);
        _bridge(tokenId);
    }

    function testCallback() public {
        MockTarget target = new MockTarget();
        bridge.setCallback(address(target), target.bridge.selector);

        uint256 tokenId = 1337;

        _bridge(tokenId);
        assert(target.bridged(tokenId));
    }

    function _bridge(uint256 tokenId) internal {
        messenger.sendMessage(address(bridge), abi.encodeWithSelector(PXBridgeL2.bridge.selector, tokenId), 100_000);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {PXBridgeL1, PXBridgeL2} from "../src/PXBridge.sol";

contract DeployL1 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address messenger = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1; // L1CrossDomainMessengerProxy
        address px = vm.envAddress("PX_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL1 bridge = new PXBridgeL1(messenger, px);
        console.log("PX bridge L1 deployed to address: ", address(bridge));

        address target = vm.envAddress("PXBRIDGE_L2_ADDRESS");
        bridge.setTarget(target);

        vm.stopBroadcast();
    }
}

contract DeployL2 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address messenger = 0x4200000000000000000000000000000000000007; // L2CrossDomainMessenger

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL2 bridge = new PXBridgeL2(messenger);
        console.log("PX bridge L2 deployed to address: ", address(bridge));

        address source = vm.envAddress("PXBRIDGE_L1_ADDRESS");
        bridge.setSource(source);

        vm.stopBroadcast();
    }
}

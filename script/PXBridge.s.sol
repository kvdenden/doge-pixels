// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {PXBridgeL1, PXBridgeL2} from "../src/PXBridge.sol";
import {BridgedPX} from "../src/BridgedPX.sol";

contract DeployL1 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address messenger = vm.envAddress("L1_XDOMAIN_MESSENGER_PROXY"); // L1CrossDomainMessengerProxy
        // address target = vm.envAddress("PXBRIDGE_L2_ADDRESS");
        address px = vm.envAddress("PX_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL1 bridge = new PXBridgeL1(messenger, px);
        // bridge.setTarget(target);
        console.log("PX bridge L1 deployed to address: ", address(bridge));

        vm.stopBroadcast();
    }
}

contract ConfigL1 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address target = vm.envAddress("PXBRIDGE_L2_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL1 bridge = PXBridgeL1(vm.envAddress("PXBRIDGE_L1_ADDRESS"));
        bridge.setTarget(target);
        console.log("PX bridge L1 target set to address: ", target);

        vm.stopBroadcast();
    }
}

contract DeployL2 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address messenger = vm.envAddress("L2_XDOMAIN_MESSENGER"); // L2CrossDomainMessenger
        // address source = vm.envAddress("PXBRIDGE_L1_ADDRESS");
        // address px = vm.envAddress("PX_L2_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL2 bridge = new PXBridgeL2(messenger);
        // bridge.setSource(source);
        // bridge.setCallback(px, BridgedPX.bridgePupper.selector);
        console.log("PX bridge L2 deployed to address: ", address(bridge));

        vm.stopBroadcast();
    }
}

contract ConfigL2 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address source = vm.envAddress("PXBRIDGE_L1_ADDRESS");
        address px = vm.envAddress("PX_L2_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PXBridgeL2 bridge = PXBridgeL2(vm.envAddress("PXBRIDGE_L2_ADDRESS"));
        bridge.setSource(source);
        bridge.setCallback(px, BridgedPX.bridgePupper.selector);
        console.log("PX bridge L2 source set to address: ", source);
        console.log("PX bridge L2 callback set to: ", px);

        vm.stopBroadcast();
    }
}

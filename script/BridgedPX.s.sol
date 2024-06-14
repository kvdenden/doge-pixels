// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {BridgedPX} from "../src/BridgedPX.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address dev = vm.envAddress("DEV_L2_ADDRESS");
        address pleasr = vm.envAddress("PLEASR_L2_ADDRESS");

        address dog20 = vm.envAddress("DOG20_L2_ADDRESS");
        string memory baseURI =
            "https://therealdoge.mypinata.cloud/ipfs/QmSjRs4dH5q2wV5mqY4ujpXNQByYyvf2A8pk6sUXgCA3QQ/";

        address bridge = vm.envAddress("PXBRIDGE_L2_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        address implementation = address(new BridgedPX());
        bytes memory data = abi.encodeCall(
            BridgedPX.__PX_init, ("Pixels of The Doge NFT", "PX", dog20, baseURI, 640, 480, dev, pleasr, bridge)
        );

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), deployer, data);
        console.log("BridgedPX proxy deployed to address: ", address(proxy));

        vm.stopBroadcast();
    }
}

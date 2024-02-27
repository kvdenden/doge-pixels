// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {PX} from "../src/PX.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address dog20 = vm.envAddress("DOG20_ADDRESS");
        string memory baseURI =
            "https://therealdoge.mypinata.cloud/ipfs/QmSjRs4dH5q2wV5mqY4ujpXNQByYyvf2A8pk6sUXgCA3QQ/";

        vm.startBroadcast(deployerPrivateKey);

        PX implementation = new PX{salt: "0x1"}();
        bytes memory data = abi.encodeCall(
            PX.__PX_init, ("Pixels of The Doge NFT", "PX", dog20, baseURI, 640, 480, deployer, vm.addr(111))
        );

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy{salt: "0x0"}(address(implementation), deployer, data);
        console.log("PX proxy deployed to address: ", address(proxy));

        vm.stopBroadcast();
    }
}

contract Upgrade is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(vm.envAddress("PX_ADDRESS"));

        PX newImplementation = new PX{salt: "0x2"}();
        proxy.upgradeTo(address(newImplementation));

        vm.stopBroadcast();
    }
}

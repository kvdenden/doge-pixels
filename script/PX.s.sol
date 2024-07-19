// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {PX} from "../src/PX.sol";
import {PX_V2} from "../src/PX_V2.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // address deployer = vm.addr(deployerPrivateKey);

        address dev = vm.envAddress("DEV_L1_ADDRESS");
        address pleasr = vm.envAddress("PLEASR_L1_ADDRESS");

        address dog20 = vm.envAddress("DOG20_ADDRESS");
        string memory baseURI =
            "https://therealdoge.mypinata.cloud/ipfs/QmSjRs4dH5q2wV5mqY4ujpXNQByYyvf2A8pk6sUXgCA3QQ/";

        vm.startBroadcast(deployerPrivateKey);

        address admin = address(new ProxyAdmin());
        console.log("PX proxy admin deployed to address: ", admin);

        address implementation = address(new PX());
        bytes memory data =
            abi.encodeCall(PX.__PX_init, ("Pixels of The Doge NFT", "PX", dog20, baseURI, 640, 480, dev, pleasr));

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), admin, data);
        console.log("PX proxy deployed to address: ", address(proxy));

        vm.stopBroadcast();
    }
}

contract Upgrade is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address bridge = vm.envAddress("PXBRIDGE_L1_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ProxyAdmin proxyAdmin = ProxyAdmin(vm.envAddress("PROXY_ADMIN_ADDRESS"));
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(vm.envAddress("PX_ADDRESS"));

        address newImplementation = address(new PX_V2());
        bytes memory data = abi.encodeCall(PX_V2.__PX_V2_init, (bridge));
        proxyAdmin.upgradeAndCall(proxy, newImplementation, data);

        vm.stopBroadcast();
    }
}

contract Bridge is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        PX_V2 px = PX_V2(vm.envAddress("PX_ADDRESS"));
        px.bridgePuppers(100);

        vm.stopBroadcast();
    }
}

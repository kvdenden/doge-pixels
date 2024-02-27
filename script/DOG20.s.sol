// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DOG20} from "../src/DOG20.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        DOG20 dog20 = new DOG20{salt: "0xd06"}(); // deploy with create2
        console.log("DOG20 deployed to address: ", address(dog20));

        vm.stopBroadcast();
    }
}

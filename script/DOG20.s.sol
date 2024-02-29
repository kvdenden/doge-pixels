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

interface IOptimismMintableERC20Factory {
    function createOptimismMintableERC20(address _remoteToken, string memory _name, string memory _symbol)
        external
        returns (address);
}

contract DeployL2 is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        address dog20 = vm.envAddress("DOG20_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        IOptimismMintableERC20Factory factory =
            IOptimismMintableERC20Factory(0x4200000000000000000000000000000000000012);

        address dog20OP = factory.createOptimismMintableERC20(dog20, "The Doge NFT", "DOG");
        console.log("Bridged DOG20 deployed to address: ", address(dog20OP));

        vm.stopBroadcast();
    }
}

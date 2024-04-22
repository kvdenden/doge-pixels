// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Test, stdStorage, StdStorage} from "forge-std/Test.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {IBridgedPX} from "../src/interfaces/IBridgedPX.sol";

import {DOG20} from "../src/DOG20.sol";
import {BridgedPX} from "../src/BridgedPX.sol";

contract MockBridge {
    address public target;

    function setTarget(address target_) public {
        target = target_;
    }

    function bridge(uint256 tokenId) external {
        IBridgedPX(target).bridgePupper(tokenId);
    }
}

contract BridgedPXTest is Test {
    using stdStorage for StdStorage;

    DOG20 public dog20;
    MockBridge public bridge;
    IBridgedPX public px;

    function setUp() public {
        address deployer = vm.addr(1337);
        address dao = vm.addr(111);

        dog20 = new DOG20();
        bridge = new MockBridge();

        address implementation = address(new BridgedPX());
        bytes memory data = abi.encodeCall(
            BridgedPX.__PX_init,
            ("Pixels of The Doge NFT", "PX", address(dog20), "", 640, 480, deployer, dao, address(bridge))
        );
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), deployer, data);

        px = IBridgedPX(address(proxy));

        dog20.approve(address(px), type(uint256).max);
        bridge.setTarget(address(px));
    }

    function testBridge(uint256 tokenId) public {
        tokenId = _boundPupper(tokenId);

        bridge.bridge(tokenId);

        assertEq(px.totalSupply(), 1);
        assertEq(px.puppersRemaining(), 1);

        vm.expectRevert("Pupper already bridged");
        bridge.bridge(tokenId);
    }

    function testBridgeAndMint() public {
        vm.expectRevert("No puppers remaining");
        px.mintPuppers(1);

        uint256 tokenId = px.INDEX_OFFSET() + 1337;
        bridge.bridge(tokenId);

        uint256 oldBalance = dog20.balanceOf(address(this));

        px.mintPuppers(1);

        assertEq(px.puppersRemaining(), 0);
        assertEq(px.ownerOf(tokenId), address(this));

        assertEq(dog20.balanceOf(address(this)), oldBalance - px.DOG_TO_PIXEL_SATOSHIS());
        assertEq(dog20.balanceOf(address(px)), px.DOG_TO_PIXEL_SATOSHIS());
    }

    function testBridgeAndMintAndBurn() public {
        uint256 tokenId = px.INDEX_OFFSET() + 1337;
        bridge.bridge(tokenId);

        uint256 oldBalance = dog20.balanceOf(address(this));

        px.mintPuppers(1);

        assertEq(px.puppersRemaining(), 0);
        assertEq(px.ownerOf(tokenId), address(this));

        assertEq(dog20.balanceOf(address(this)), oldBalance - px.DOG_TO_PIXEL_SATOSHIS());
        assertEq(dog20.balanceOf(address(px)), px.DOG_TO_PIXEL_SATOSHIS());

        uint256[] memory puppers = new uint256[](1);
        puppers[0] = tokenId;

        px.burnPuppers(puppers);

        assertEq(px.puppersRemaining(), 1);

        vm.expectRevert("ERC721: invalid token ID");
        px.ownerOf(tokenId);
    }

    function testBridgeMultiple() public {
        uint256 t1 = px.INDEX_OFFSET() + 1111;
        uint256 t2 = px.INDEX_OFFSET() + 2222;
        uint256 t3 = px.INDEX_OFFSET() + 3333;

        bridge.bridge(t1); // bridge first pupper

        // [t1|]
        assertEq(_indexToPupper(0), t1);
        assertEq(_pupperToIndex(t1), 0);
        assertEq(px.puppersRemaining(), 1);

        px.mintPuppers(1);

        // [|t1]
        assertEq(px.puppersRemaining(), 0);
        assertEq(px.ownerOf(t1), address(this));

        bridge.bridge(t2); // bridge with no available puppers, only used ones

        // bridged pupper added before used pool
        // [t2|t1]
        assertEq(_indexToPupper(0), t2);
        assertEq(_indexToPupper(1), t1);
        assertEq(_pupperToIndex(t1), 1);
        assertEq(_pupperToIndex(t2), 0);
        assertEq(px.puppersRemaining(), 1);

        px.mintPuppers(1);

        // [|t2,t1]
        assertEq(px.puppersRemaining(), 0);
        assertEq(px.ownerOf(t2), address(this));

        px.burnPuppers(_arrayOf(t1));

        // burned pupper moved to available pool
        // [t1|t2]
        assertEq(_indexToPupper(0), t1);
        assertEq(_indexToPupper(1), t2);
        assertEq(_pupperToIndex(t1), 0);
        assertEq(_pupperToIndex(t2), 1);
        assertEq(px.puppersRemaining(), 1);

        bridge.bridge(t3); // bridge with both available and used puppers

        // bridged pupper added to end of available pool
        // [t1,t3|t2]
        assertEq(_indexToPupper(0), t1);
        assertEq(_indexToPupper(1), t3);
        assertEq(_indexToPupper(2), t2);
        assertEq(_pupperToIndex(t1), 0);
        assertEq(_pupperToIndex(t2), 2);
        assertEq(_pupperToIndex(t3), 1);
        assertEq(px.puppersRemaining(), 2);
    }

    function _boundPupper(uint256 pupper) internal view returns (uint256) {
        return px.INDEX_OFFSET() + (pupper % 460 * 640); // restrict to valid token ids
    }

    function _indexToPupper(uint256 index) internal view returns (uint256) {
        return _loadStorage(154, px.INDEX_OFFSET() + index);
    }

    function _pupperToIndex(uint256 pupper) internal view returns (uint256) {
        return _loadStorage(155, pupper) - px.INDEX_OFFSET();
    }

    function _loadStorage(uint256 slot, uint256 key) internal view returns (uint256) {
        uint256 keySlot = uint256(keccak256(abi.encode(key, slot)));
        bytes32 data = vm.load(address(px), bytes32(keySlot));

        return uint256(data);
    }

    function _arrayOf(uint256 value) internal pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](1);
        arr[0] = value;
        return arr;
    }
}

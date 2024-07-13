// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IPXBridge {
    event Bridge(uint256 indexed tokenId);

    function bridge(uint256[] memory tokenIds) external;
}

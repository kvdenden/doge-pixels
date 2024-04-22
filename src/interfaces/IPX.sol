// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IPX is IERC721 {
    function mintPuppers(uint256 qty) external;
    function burnPuppers(uint256[] memory puppers) external;

    function puppersRemaining() external view returns (uint256);
    function totalSupply() external view returns (uint256);

    function DOG_TO_PIXEL_SATOSHIS() external view returns (uint256);
    function INDEX_OFFSET() external view returns (uint256);
    function MAGIC_NULL() external view returns (uint256);
}

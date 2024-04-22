// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IPX} from "./IPX.sol";

interface IBridgedPX is IPX {
    function bridgePupper(uint256 pupper) external;
}

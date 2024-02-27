// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PX} from "./PX.sol";

/// @custom:oz-upgrades-from PX
contract PX_V2 is PX {
    function version() public pure returns (string memory) {
        return "v2";
    }
}

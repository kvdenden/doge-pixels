// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PX} from "./PX.sol";
import {IPXBridge} from "./PXBridge.sol";

/// @custom:oz-upgrades-from PX
contract PX_V2 is PX {
    event Bridge(uint256 indexed tokenId);

    address public BRIDGE;

    function __PX_V2_init(address bridge_) public reinitializer(2) {
        require(bridge_ != address(0), "PX_V2: invalid bridge");
        BRIDGE = bridge_;
    }

    function bridgePuppers(uint256 qty) external {
        require(qty <= puppersRemaining, "No puppers remaining");

        uint256 LAST_INDEX = INDEX_OFFSET + puppersRemaining - 1;
        for (uint256 i; i < qty; ++i) {
            uint256 index = LAST_INDEX - i; // take last pupper
            if (indexToPupper[index] == MAGIC_NULL) {
                indexToPupper[index] = index; // lazy initialization (see mintPuppers)
            }
            uint256 pupper = indexToPupper[index];
            pupperToIndex[pupper] = index; // TODO: do we need to do this?

            _bridge(pupper);
        }
        puppersRemaining -= qty;
    }

    function _bridge(uint256 tokenId) internal {
        IPXBridge(BRIDGE).bridge(tokenId);
        emit Bridge(tokenId);
    }
}

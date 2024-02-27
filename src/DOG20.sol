// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DOG20 is ERC20 {
    constructor() ERC20("The Doge NFT", "DOG") {
        _mint(msg.sender, 16969696969 * 10 ** 18);
    }
}

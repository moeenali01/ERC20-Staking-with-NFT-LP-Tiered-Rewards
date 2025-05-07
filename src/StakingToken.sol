// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    uint256 private initialSupply = 1000000 * 10 ** 18;

    constructor() ERC20("Moin Token", "MTK") {
        // Mint the initial supply to the deployer's address
        _mint(msg.sender, initialSupply);
    }
}

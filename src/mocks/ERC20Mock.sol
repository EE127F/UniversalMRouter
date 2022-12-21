// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        mint(msg.sender, 9999999999999999999999999);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
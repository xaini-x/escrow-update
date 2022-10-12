// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("test", "tt") {
        _mint(msg.sender , 1000 **18);
    }

    function transfer(address to , address from ,uint amount)external returns(bool ){
        _transfer(to ,from,amount);
        return true;
    }
}


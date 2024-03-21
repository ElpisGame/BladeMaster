// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// import "hardhat/console.sol";

contract fakeUSDT is ERC20Permit {

    constructor() ERC20("fake USDT", "fUSDT") ERC20Permit("fake USDT") {
        _mint(msg.sender, 10 ** 30);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function requestU() public {
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}

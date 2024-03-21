// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "hardhat/console.sol";

contract ProxyTest {
    // override saleInfoId for upgrade testing
    function saleInfoId() public pure returns(uint256) {
        return 123;
    }
}

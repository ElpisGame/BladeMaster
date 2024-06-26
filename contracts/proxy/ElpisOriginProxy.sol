// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

// import "hardhat/console.sol";

contract ElpisOriginProxy is TransparentUpgradeableProxy {

    constructor(address _logic, address initialOwner, bytes memory _data) payable TransparentUpgradeableProxy(_logic, initialOwner, _data) {}

    function implementation() public view returns (address) {
        return _implementation();
    }

    function proxyAdmin() public view returns (address) {
        return ERC1967Utils.getAdmin();
    }
}
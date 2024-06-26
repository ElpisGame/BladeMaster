// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat/console.sol";

contract Test {
    using ECDSA for bytes32;

    function verify(uint256 a, uint256 b, bytes calldata signature) public view returns(bool){
        bytes32 hash = keccak256(abi.encodePacked(a, b));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return (msg.sender == prefixedHash.recover(signature));
    }

    function verify2(bytes32 hash, bytes calldata signature) public view returns(bool){
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        // console.log(prefixedHash);
        return (msg.sender == prefixedHash.recover(signature));
    }

    function verify3(address _nftAddress, uint256 _nftId, address _token, uint256 _amount, bytes calldata signature) public view returns(bool){
        bytes32 hash = keccak256(abi.encodePacked(_nftAddress, _nftId, _token, _amount));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return (msg.sender == prefixedHash.recover(signature));
    }

    function kec(uint256 a, uint256 b) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    function kec2(address _nftAddress, uint256 _nftId, address _token, uint256 _amount) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_nftAddress, _nftId, _token, _amount));
    }
}
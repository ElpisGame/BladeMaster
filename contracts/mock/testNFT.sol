// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "hardhat/console.sol";

contract testNFT is ERC721 {

    uint256 public nextTokenId;

    constructor() ERC721("Test NFT", "tNFT") {
        mint(msg.sender);
    }

    function mint(address _to) public {
        _mint(_to, nextTokenId);
        ++nextTokenId;
    }

    function mint() public {
        _mint(msg.sender, nextTokenId);
        ++nextTokenId;
    }
}

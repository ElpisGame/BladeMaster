// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import "hardhat/console.sol";

contract BladeMasterAsset is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public _tokenURI = "https://nft.tojoy.org/metadata.example.json";

    constructor() ERC721("TestAsset", "TA") {}

    function mintAsset(
        address _to
    ) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId);
        // TODO: set tokenURI

        _tokenIds.increment();
        return newItemId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return _tokenURI;
    }

    function DEBUG_resetTokenURI(string memory _newTokenURI) public {
        _tokenURI = _newTokenURI;
    }
}

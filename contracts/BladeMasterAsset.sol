// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import "hardhat/console.sol";

contract BladeMasterAsset is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("BladeMasterAsset", "BMA") {}

    function mintAsset(
        address _to,
        string memory _tokenURI
    ) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId);
        // TODO: set tokenURI

        _tokenIds.increment();
        return newItemId;
    }
}

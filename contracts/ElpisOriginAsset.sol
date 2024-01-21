// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

contract ElpisOriginAsset is ERC721Enumerable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public _tokenURI = "https://nft.tojoy.org/char{id}.metadata.json";
    mapping(uint256 => string) public _tokenURIs;

    constructor(
        address _minter,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _minter);
        _grantRole(MINTER_ROLE, _minter);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        _requireMinted(_tokenId);
        string memory uri = _tokenURIs[_tokenId];
        return bytes(uri).length > 0 ? uri : _tokenURI;
    }

    function mintAsset(
        address _to,
        string memory _uniqueTokenURI
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId);
        if (bytes(_uniqueTokenURI).length > 0) {
            _tokenURIs[newItemId] = _uniqueTokenURI;
        }
        _tokenIds.increment();
        return newItemId;
    }

    function setTokenURI(string memory _newTokenURI) public onlyRole(MINTER_ROLE) {
        _tokenURI = _newTokenURI;
        // emit URI(_newTokenURI, _tokenId);
    }

    function burn(uint256 _id) public onlyRole(MINTER_ROLE) {
        _burn(_id);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
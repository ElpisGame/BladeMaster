// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./utils/ERC721A.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

contract ElpisOriginAsset721A is ERC721A, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public _tokenURI = "https://assets.elpisgame.io/test/arika.json";
    mapping(uint256 => string) public _tokenURIs;

    constructor(
        address _minter,
        string memory _name,
        string memory _symbol
    ) ERC721A(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _minter);
        _grantRole(MINTER_ROLE, _minter);
    }

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId();
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_exists(_tokenId), "ElpisOriginAsset: token not exist");
        string memory uri = _tokenURIs[_tokenId];
        return bytes(uri).length > 0 ? uri : _tokenURI;
    }

    function mintAsset(
        address _to,
        string memory _uniqueTokenURI
    ) public onlyRole(MINTER_ROLE) {
        if (bytes(_uniqueTokenURI).length > 0) {
            _tokenURIs[_nextTokenId()] = _uniqueTokenURI;
        }
        _mint(_to, 1);
    }

    function mintAssetBatch(
        address _to,
        uint256 _amount
    ) public onlyRole(MINTER_ROLE) {
        _mint(_to, _amount);
    }

    function setTokenURI(
        string memory _newTokenURI
    ) public onlyRole(MINTER_ROLE) {
        _tokenURI = _newTokenURI;
    }

    function updateUniqueTokenURI(
        uint256 _tokenId,
        string memory _newTokenURI
    ) public onlyRole(MINTER_ROLE) {
        _tokenURIs[_tokenId] = _newTokenURI;
        // emit URI(_newTokenURI, _tokenId);
    }

    function burn(uint256 _id) public onlyRole(MINTER_ROLE) {
        _burn(_id);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

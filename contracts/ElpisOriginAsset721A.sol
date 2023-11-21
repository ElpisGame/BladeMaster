// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./utils/ERC721A.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

contract ElpisOriginAsset721A is ERC721A, AccessControl {

    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.    
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public _tokenURI;
    mapping(uint256 => string) public _tokenURIs;

    constructor(
        address _minter,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC721A(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, _minter);
        _grantRole(MINTER_ROLE, _minter);
        _tokenURI = _uri;
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

    function transferMinterAdmin(address _newAdmin) public {
        grantRole(DEFAULT_ADMIN_ROLE, _newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
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
        emit MetadataUpdate(_tokenId);
    }

    function updateMetadata(
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) public onlyRole(MINTER_ROLE) {
        emit BatchMetadataUpdate(_fromTokenId, _toTokenId);
    }

    function burn(uint256 _id) public onlyRole(MINTER_ROLE) {
        _burn(_id);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, AccessControl) returns (bool) {
        // 0x49064906 used for metadata update
        return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
    }
}

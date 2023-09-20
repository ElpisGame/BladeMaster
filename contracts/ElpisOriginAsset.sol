// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "hardhat/console.sol";

contract ElpisOriginAsset is ERC1155Supply, Ownable, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    string public name;
    string public symbol;

    string public _baseURI = "";

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor(
        address _minter,
        string memory _name,
        string memory _symbol
    ) ERC1155("https://nft.tojoy.org/char{id}.metadata.json") {
        name = _name;
        symbol = _symbol;
        _grantRole(MINTER_ROLE, _minter);
        _grantRole(TRANSFER_ROLE, _minter);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId), "ElpisOriginAsset: token dose not exist");
        string memory tokenURI = _tokenURIs[tokenId];

        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return
            bytes(tokenURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenURI))
                : super.uri(tokenId);
    }

    function mintNewAsset(
        address _to,
        uint256 _amount,
        bytes memory _data
    ) public returns (uint256) {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "ElpisOriginAsset: caller is not a minter"
        );
        uint256 newItemId = _tokenIds.current();
        _mint(_to, newItemId, _amount, _data);
        _tokenIds.increment();
        return newItemId;
    }

    function expandAsset(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "ElpisOriginAsset: caller is not a minter"
        );
        _mint(_to, _tokenId, _amount, _data);
    }

    function setTokenURI(string memory _newTokenURI, uint256 _tokenId) public {
        _setURI(_tokenId, _newTokenURI);
        emit URI(_newTokenURI, _tokenId);
    }

    function setBaseURI(string memory _newBaseURI) public {
        _setBaseURI(_newBaseURI);
    }

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function _setURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }

    /**
     * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    function burn(address _from, uint256 _id, uint256 _amount) public {
        _burn(_from, _id, _amount);
    }

    function burnBatch(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) public {
        _burnBatch(_from, _ids, _amounts);
    }

    // TODO: does this override ERC721?
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

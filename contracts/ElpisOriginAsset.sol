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

    // string public _tokenURI = "https://nft.tojoy.org/metadata.example.json";

    constructor(
        address _minter,
        string memory _name,
        string memory _symbol
    ) ERC1155("https://nft.tojoy.org/char1.metadata.json") {
        name = _name;
        symbol = _symbol;
        _grantRole(MINTER_ROLE, _minter);
        _grantRole(TRANSFER_ROLE, _minter);
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

    function mintAsset(
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

    function DEBUG_resetTokenURI(
        string memory _newTokenURI,
        uint256 _tokenId
    ) public {
        _setURI(_newTokenURI);
        emit URI(_newTokenURI, _tokenId);
    }

    function DEBUG_updateTokenURI(uint256 _tokenId) public {
        emit URI(uri(_tokenId), _tokenId);
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

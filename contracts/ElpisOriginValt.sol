// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// import "hardhat/console.sol";

contract ElpisOriginValt is ERC165 {

    Event LockAsset(address indexed owner, address indexed token, uint256 indexed tokenId);
    Event ReleaseAsset(address indexed owner, address indexed token, uint256 indexed tokenId);

    // tokenAddress => (tokenId => owner)
    mapping(address => mapping(uint256 => address)) public lockedAssets;

    function lockAsset(address _token, uint256 _tokenId) public {
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenId);
        lockedAssets[_token][_tokenId] = msg.sender;
        emit LockAsset(msg.sender, _token, _tokenId);
    }

    function releaseAsset(address _token, uint256 _tokenId) public {
        IERC721(_token).safeTransferFrom(address(this), lockedAssets[_token][_tokenId], _tokenId);
        lockedAssets[_token][_tokenId] = address(0);
        emit ReleaseAsset(lockedAssets[_token][_tokenId], _token, _tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

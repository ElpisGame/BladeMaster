// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import "hardhat/console.sol";

contract ElpisOriginValt is ERC165, Ownable {
    event Pay(
        uint256 indexed nonce,
        address indexed token,
        uint256 indexed amount
    );

    event LockAsset(
        address indexed owner,
        address indexed token,
        uint256 indexed tokenId
    );

    event ReleaseAsset(
        address indexed owner,
        address indexed token,
        uint256 indexed tokenId
    );

    address public pocket;
    // tokenAddress => (tokenId => owner)
    mapping(address => mapping(uint256 => address)) public lockedAssets;

    constructor(address _pocket) {
        pocket = _pocket;
    }

    function setPocketAddress(address _newPocket) public onlyOwner {
        pocket = _newPocket;
    }

    function pay(uint256 _nonce, address _token, uint256 _amount) public {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        emit Pay(_nonce, _token, _amount);
    }

    function withdrawFund(address _token, uint256 _amount) public {
        IERC20(_token).transferFrom(address(this), pocket, _amount);
    }

    function withdrawAsset(address _token, uint256 _tokenId) public onlyOwner {
        require(
            lockedAssets[_token][_tokenId] == address(0),
            "ElpisOriginValt: token has owner"
        );
        IERC721(_token).safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function lockAsset(address _token, uint256 _tokenId) public {
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenId);
        lockedAssets[_token][_tokenId] = msg.sender;
        emit LockAsset(msg.sender, _token, _tokenId);
    }

    function releaseAsset(address _token, uint256 _tokenId) public {
        IERC721(_token).safeTransferFrom(
            address(this),
            lockedAssets[_token][_tokenId],
            _tokenId
        );
        lockedAssets[_token][_tokenId] = address(0);
        emit ReleaseAsset(lockedAssets[_token][_tokenId], _token, _tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

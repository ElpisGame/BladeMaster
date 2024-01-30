// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IElpisOriginAsset.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import "hardhat/console.sol";

contract ElpisOriginValt is ERC165, IERC721Receiver, Ownable {

    event SaleSetup(
        uint256 indexed saleInfoId,
        address indexed nftAddress,
        uint256 indexed nftId,
        address tokenAddress,
        uint256 price
    );

    event DistributeAsset(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed nftId
    );

    event Pay(
        uint256 indexed saleId,
        address indexed nftAddress,
        uint256 indexed nftId,
        address tokenAddress,
        uint256 price
    );

    event LockToken(
        address indexed owner,
        address indexed token,
        uint256 indexed amount
    );

    event UnlockToken(
        address indexed owner,
        address indexed token,
        uint256 indexed amount
    );

    event LockAsset(
        address indexed owner,
        address indexed token,
        uint256 indexed tokenId
    );

    event UnlockAsset(
        address indexed owner,
        address indexed token,
        uint256 indexed tokenId
    );

    struct SaleInfo {
        address nftAddress;
        uint256 nftId;
        address tokenAddress;
        uint256 amount;
    }

    address public pocket;

    uint256 public saleInfoId = 1;
    mapping(uint256 => SaleInfo) public saleInfos;
    // nftAddress[nftId] => saleInfId
    mapping(address => mapping(uint256 => uint256)) public nftToSaleInfo;

    // user address => token address => locked amount
    mapping(address => mapping(address => uint256)) public lockedToken;
    // nft address => nft id => user address
    mapping(address => mapping(uint256 => address)) public lockedAssets;

    constructor(address _pocket) {
        pocket = _pocket;
    }

    function withdrawFund(address _token, uint256 _amount) public {
        IERC20(_token).transfer(pocket, _amount);
    }

    function setPocketAddress(address _newPocket) public onlyOwner {
        require(_newPocket != address(0), "ElpisOriginValt: cannot set pocket to address zero");
        pocket = _newPocket;
    }

    function setupSale(address _nftAddress, uint256 _nftId, address _token, uint256 _amount) public onlyOwner {
        require(IERC721(_nftAddress).ownerOf(_nftId) == address(this), "ElpisOriginValt: missing the nft");
        saleInfos[saleInfoId] = SaleInfo(_nftAddress, _nftId, _token, _amount);
        nftToSaleInfo[_nftAddress][_nftId] = saleInfoId;
        emit SaleSetup(saleInfoId, _nftAddress, _nftId, _token, _amount);
        ++saleInfoId;
    }

    function withdrawAsset(address _nftAddress, uint256 _nftId) public onlyOwner {
        require(
            lockedAssets[_nftAddress][_nftId] == address(0),
            "ElpisOriginValt: token has owner"
        );
        saleInfos[nftToSaleInfo[_nftAddress][_nftId]] = SaleInfo(address(0), 0, address(0), 0);
        nftToSaleInfo[_nftAddress][_nftId] = 0;
        IERC721(_nftAddress).safeTransferFrom(address(this), msg.sender, _nftId);
    }

    function distributeAsset(address _newOwner, address _nftAddress, uint256 _nftId) public onlyOwner {
        require(lockedAssets[_nftAddress][_nftId] == address(0), "ElpisOriginValt: nft not available");
        lockedAssets[_nftAddress][_nftId] = _newOwner;
        emit DistributeAsset(_newOwner, _nftAddress, _nftId);
    }

    function pay(uint256 saleId) public {
        IERC20(saleInfos[saleId].tokenAddress).transferFrom(msg.sender, address(this), saleInfos[saleId].amount);
        IERC721(saleInfos[saleId].nftAddress).transferFrom(address(this), msg.sender, saleInfos[saleId].nftId);
        emit Pay(saleId, saleInfos[saleId].nftAddress, saleInfos[saleId].nftId, saleInfos[saleId].tokenAddress, saleInfos[saleId].amount);
    }

    function lockToken(address _token, uint256 _amount) public {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        lockedToken[msg.sender][_token] += _amount;
        emit LockToken(msg.sender, _token, _amount);
    }

    function unlockToken(address _token, uint256 _amount) public {
        require(_amount <= lockedToken[msg.sender][_token], "ElpisOriginValt: exceed max amount");
        IERC20(_token).transfer(
            msg.sender,
            _amount
        );
        lockedToken[msg.sender][_token] -= _amount;
        emit UnlockToken(msg.sender, _token, _amount);
    }

    function lockAsset(address _nftAddress, uint256 _nftId) public {
        IERC721(_nftAddress).transferFrom(msg.sender, address(this), _nftId);
        lockedAssets[_nftAddress][_nftId] = msg.sender;
        emit LockAsset(msg.sender, _nftAddress, _nftId);
    }

    function unlockAsset(address _nftAddress, uint256 _nftId) public {
        require(msg.sender == lockedAssets[_nftAddress][_nftId], "ElpisOriginValt: not the owner");
        IERC721(_nftAddress).safeTransferFrom(
            address(this),
            lockedAssets[_nftAddress][_nftId],
            _nftId
        );
        lockedAssets[_nftAddress][_nftId] = address(0);
        IElpisOriginAsset(_nftAddress).updateMetadata(_nftId);
        emit UnlockAsset(msg.sender, _nftAddress, _nftId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract ElpisOriginMarket is Ownable {

    event itemListed(address indexed owner, address indexed nftAddress, uint256 indexed nftId);
    event itemSold(address indexed buyer, address indexed nftAddress, uint256 indexed nftId);
    event newBid(address indexed bidder, address indexed nftAddress, uint256 indexed nftId);

    struct SaleInfo {
        address owner;

        address nftAddress;
        uint256 nftId;

        address paymentTokenAddress;
        uint256 listedPrice;

        address lastBidder;
        uint256 lastBidPrice;
        uint256 startTime;
        uint256 endTime;
    }

    uint256 public saleId;
    uint256 public fee; // base of 10000
    uint256 public minBid;
    uint256 constant BASE_RATIO = 10000;
    uint256 public maxAuctionPeriod = 30 days;

    mapping(uint256 => SaleInfo) public saleInfos;
    mapping(address => mapping(address =>uint256)) public unclaimedMoney;

    function adjustFee(uint256 _newFee) public onlyOwner {
        require(_newFee <= BASE_RATIO, "ElpisOriginMarket: fee exceed max value");
        fee = _newFee;
    }

    function adjustMinBid(uint256 _newBid) public onlyOwner {
        require(_newBid <= BASE_RATIO, "ElpisOriginMarket: bid exceed max value");
        minBid = _newBid;
    }

    function withdrawFee(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(msg.sender, IERC20(_tokenAddress).balanceOf(address(this)));
    }

    function list(
        address _nftaddress,
        uint256 _nftId,
        address _paymentTokenAddress,
        uint256 _price
    ) public returns (uint256) {
        IERC721(_nftaddress).transferFrom(msg.sender, address(this), _nftId);
        unchecked {
            ++saleId;
        }
        saleInfos[saleId].owner = msg.sender;
        saleInfos[saleId].nftAddress = _nftaddress;
        saleInfos[saleId].nftId = _nftId;
        saleInfos[saleId].paymentTokenAddress = _paymentTokenAddress;
        saleInfos[saleId].listedPrice = _price;
        emit itemListed(msg.sender, _nftaddress, _nftId);
        return saleId;
    }

    function unlist(uint256 _saleId) public {
        require(saleInfos[_saleId].owner == msg.sender, "ElpisOriginMarket: only the owner can unlist");
        IERC721(saleInfos[_saleId].nftAddress).transferFrom(address(this), msg.sender, saleInfos[_saleId].nftId);
        saleInfos[_saleId].nftAddress = address(0);
    }

    function listForAuction(
        address _nftaddress,
        uint256 _nftId,
        address _paymentTokenAddress,
        uint256 _startingPrice,
        uint256 _timeFromNow
    ) public returns (uint256) {
        return listForAuction(_nftaddress, _nftId, _paymentTokenAddress, _startingPrice, block.timestamp, block.timestamp + _timeFromNow);
    }

    function listForAuction(
        address _nftaddress,
        uint256 _nftId,
        address _paymentTokenAddress,
        uint256 _startingPrice,
        uint256 _startTime,
        uint256 _endTime
    ) public returns (uint256) {
        require(_startTime >= block.timestamp, "ElpisOriginMarket: invalid starting time");
        require(_endTime - _startTime <= maxAuctionPeriod, "ElpisOriginMarket: exceed max period");
        IERC721(_nftaddress).transferFrom(msg.sender, address(this), _nftId);
        unchecked {
            ++saleId;
        }
        saleInfos[saleId].owner = msg.sender;
        saleInfos[saleId].nftAddress = _nftaddress;
        saleInfos[saleId].nftId = _nftId;
        saleInfos[saleId].paymentTokenAddress = _paymentTokenAddress;
        saleInfos[saleId].lastBidPrice = _startingPrice;
        saleInfos[saleId].startTime = _startTime;
        saleInfos[saleId].endTime = _endTime;
        emit itemListed(msg.sender, _nftaddress, _nftId);
        return saleId;
    }

    function purchase(uint256 _saleId) public {
        require(saleInfos[_saleId].nftAddress != address(0), "ElpisOriginMarket: invalid sale");
        require(saleInfos[_saleId].endTime == 0, "ElpisOriginMarket: cannot purchase auction item");
        // fee
        IERC20(saleInfos[_saleId].paymentTokenAddress).transferFrom(
            msg.sender,
            address(this),
            saleInfos[_saleId].listedPrice
        );
        // payment
        IERC20(saleInfos[_saleId].paymentTokenAddress).transfer(
            saleInfos[_saleId].owner,
            saleInfos[_saleId].listedPrice - (saleInfos[_saleId].listedPrice * fee / BASE_RATIO)
        );
        // transfer NFT
        IERC721(saleInfos[_saleId].nftAddress).transferFrom(
            address(this),
            msg.sender,
            saleInfos[_saleId].nftId
        );
        emit itemSold(msg.sender, saleInfos[_saleId].nftAddress, saleInfos[_saleId].nftId);
        saleInfos[_saleId].nftAddress = address(0);
    }

    function bid(uint256 _saleId, uint256 _newBid) public {
        require(saleInfos[_saleId].nftAddress != address(0), "ElpisOriginMarket: invalid sale");
        require(block.timestamp >= saleInfos[_saleId].startTime && 
            block.timestamp <= saleInfos[_saleId].endTime, 
            "ElpisOriginMarket: bad timing");
        require(_newBid >= saleInfos[_saleId].lastBidPrice * (minBid + BASE_RATIO) / BASE_RATIO,
            "ElpisOriginMarket: bid too low");
        if (saleInfos[_saleId].lastBidder != address(0)) {
            IERC20(saleInfos[_saleId].paymentTokenAddress).transfer(
                saleInfos[_saleId].lastBidder,
                saleInfos[_saleId].lastBidPrice
            );
        }
        saleInfos[_saleId].lastBidPrice = _newBid;
        saleInfos[_saleId].lastBidder = msg.sender;
        IERC20(saleInfos[_saleId].paymentTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _newBid
        );
        emit newBid(msg.sender, saleInfos[_saleId].nftAddress, saleInfos[_saleId].nftId);
    }

    function claim(uint256 _saleId) public {
        require(saleInfos[_saleId].endTime <= block.timestamp, "ElpisOriginMarket: active auction");
        IERC20(saleInfos[_saleId].paymentTokenAddress).transfer(
            saleInfos[_saleId].owner,
            saleInfos[_saleId].lastBidPrice - (saleInfos[_saleId].lastBidPrice * fee / BASE_RATIO)
        );
        IERC721(saleInfos[_saleId].nftAddress).transferFrom(
            address(this),
            saleInfos[_saleId].lastBidder,
            saleInfos[_saleId].nftId
        );
        emit itemSold(msg.sender, saleInfos[_saleId].nftAddress, saleInfos[_saleId].nftId);
        saleInfos[_saleId].nftAddress = address(0);
    }
}

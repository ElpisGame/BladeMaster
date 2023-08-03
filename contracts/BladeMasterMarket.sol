// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "hardhat/console.sol";

contract BladeMasterMarket {
    struct Sale {
        address offerer;
        address tokenAddress;
        uint256 tokenId;
        // assume we only accepts BM sub-token as payment then we don't need this parameter
        // address paymentToken;
        uint256 price;
        uint256 state;
    }

    uint256 public saleIndex;
    uint256 public fee;

    mapping(uint256 => Sale) public sales;

    function setup(address _token, uint256 _tokenId, uint256 _price) public {
        IERC721(_token).transferFrom(msg.sender, address(this), _tokenId);
        sales[saleIndex].offerer = msg.sender;
        sales[saleIndex].tokenAddress = _token;
        sales[saleIndex].tokenId = _tokenId;
        sales[saleIndex].price = _price;
        sales[saleIndex].state = 2;
        unchecked {
            ++saleIndex;
        }
    }

    function trade(uint256 _saleId) public {
        require(sales[_saleId].state == 1, "BladeMasterMarket: not for sale");
        // TODO: charge fees
        IERC20(sales[_saleId].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            sales[_saleId].price
        );
        IERC721(sales[_saleId].tokenAddress).transferFrom(
            address(this),
            msg.sender,
            sales[_saleId].tokenId
        );
        sales[_saleId].state = 2;
    }

    function claim(uint256 _saleId) public {
        require(
            sales[_saleId].offerer == msg.sender,
            "BladeMasterMarket: not the offerer"
        );
        IERC20(sales[_saleId].tokenAddress).transfer(
            msg.sender,
            sales[_saleId].price
        );
    }
}

# Elpis: Origin Asset

The NFT tokens in Elpis: Origin are derived from ERC721Enumerable. Common ERC721 APIs can be found at: https://docs.openzeppelin.com/contracts/4.x/api/token/erc721.

Here are some quick references, the `view` keyword indicates that this function is a read-only function.

-   `mintAsset(address  to) onlyOwner`
    Mint a asset and transfer it to address `to`. Server needs to keep track of the tokenId and generate the corresponding metadata file.

-   `totalSupply() view returns (uint256)`
    Return total number of token minted.

-   `tokenByIndex(uint256  index) view returns (uint256)`
    Return the token id by `index`.

-   `tokenOfOwnerByIndex(address  owner, uint256  index) view returns (uint256)`
    Return the token id by the `index` of the token that address(`owner`) holds.

-   `tokenURI(uint256  tokenId) view returns (string  memory)`
    Returns the link to the metadata of the `tokenId` token.

# Elpis: Origin Marketplace

Elpis: Origin provides a marketplace for users to trade their in-game assets using Elpis: Origin Token.

-   `setup(address  _token, uint256  _tokenId, uint256  _price) returns (uint256)`
    Allow user to list their asset for sale, return the id recorded for this sale.
    `_token`: the Elpis: Origin Asset token address;
    `_tokenId`: the token id the user wishes to list for sale;
    `_price`: the number of the token the user wishes to sale for.

-   `trade(uint256  _saleId)`
    Purchase the listed asset with the id of `_saleId`.

-   `claim(uint256  _saleId)`
    After a successful sale, the seller will be able to claim the token the buyer paid for the asset with the id of `_saleId`.

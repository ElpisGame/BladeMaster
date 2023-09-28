# ERC20

-   `approve(address  spender, uint256  amount)`
    Set the amount of token `amount` allowed to be spent by `spender`.

# Elpis: Origin Asset

The NFT tokens in Elpis: Origin are derived from ERC721. Common ERC721 APIs can be found at: https://docs.openzeppelin.com/contracts/4.x/erc721.

Here are some quick references, the `view` keyword indicates that this function is a read-only function.

-   `mintAsset(address  _to) onlyOwner`
    Mint `_amount` number of assets and transfer them to address `to`. Server needs to keep track of the tokenId and generate the corresponding metadata file.

-   `totalSupply() view returns (uint256)`
    Return total number of token minted with token id `id`.

-   `balanceOf(address  account, uint256  id) view returns (uint256)`
    Return the amount of token owned by `account` with token id `id`.

-   `tokenURI(uint256 tokenId) view returns (string  memory)`
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

# Elpis: Origin Vault

-   `nonce()`
    Return the nonce value for next transaction.

-   `pay(uint256  _nonce, address  _token, uint256  _amount)`
    Payment for certain item.
    `_nonce`: one-time assigned nonce for the purchase;
    `_token`: token used for the purchase;
    `_amount`: the amount of token paid.

-   `lockAsset(address  _token, uint256  _tokenId)`
    Import NFT to game.
    `_token`: NFT contract address;
    `_tokenId`: NFT corresponding token id.

-   `releaseAsset(address  _token, uint256  _tokenId)`
    Export NFT to wallet which imported the NFT.
    `_token`: NFT contract address;
    `_tokenId`: NFT corresponding token id.

## Purchase flowchart:

<iframe width="768" height="432" src="https://miro.com/app/live-embed/uXjVMigIuJc=/?moveToViewport=-1012,-541,1612,904&embedId=966780456345" frameborder="0" scrolling="no" allow="fullscreen; clipboard-read; clipboard-write" allowfullscreen></iframe>

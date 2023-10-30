# ERC20

-   `approve(address  spender, uint256  amount)`
    Set the amount of token `amount` allowed to be spent by `spender`.

# Elpis: Origin Asset

The NFT tokens in Elpis: Origin are derived from ERC721A. Common ERC721 APIs can be found at: https://docs.openzeppelin.com/contracts/4.x/erc721.

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

-   `lockToken(address  _token, uint256  _amount)`
    Import NFT to game.
    `_token`: token contract address;
    `_amount`: the amount of token.
    emit `LockToken(msg.sender, _token, _amount)`

-   `releaseToken(address  _token, uint256  _amount)`
    Export NFT to wallet which imported the NFT.
    `_token`: NFT contract address;
    `_amount`: the amount of token.
    emit `ReleaseToken(msg.sender, _token, _amount)`

-   `lockAsset(address  _token, uint256  _tokenId)`
    Import NFT to game.
    `_token`: NFT contract address;
    `_tokenId`: NFT corresponding token id.
    emit `LockAsset(msg.sender, _token, _tokenId)`

-   `releaseAsset(address  _token, uint256  _tokenId)`
    Export NFT to wallet which imported the NFT.
    `_token`: NFT contract address;
    `_tokenId`: NFT corresponding token id.
    emit `LockAsset(msg.sender, _token, _tokenId)`

## Deployed contracts:

### Polygon testnet (Mumbai)

| Contract | Address                                    |
| -------- | ------------------------------------------ |
| USDT     | 0x7DE99fe2687827cC60d38f626549226F0a68269A |
| NFT      | 0x6B8a176Ab8e37dF3542fb34030Be66229a1361da |
| Vault    | 0xdd9E7EEe53Bd39ca687aF278a8bDfe1e53fE9C03 |

### Polygon mainnet

| Contract | Address |
| -------- | ------- |
| USDT     |         |
| NFT      |         |
| Vault    |         |

## NFT lifecycle:

<iframe width="768" height="432" src="https://miro.com/app/live-embed/uXjVMtoNo5U=/?moveToViewport=-1631,-516,1926,1080&embedId=316077058569" frameborder="0" scrolling="no" allow="fullscreen; clipboard-read; clipboard-write" allowfullscreen></iframe>

## Purchase flowchart:

<iframe width="768" height="432" src="https://miro.com/app/live-embed/uXjVMigIuJc=/?moveToViewport=-1012,-541,1612,904&embedId=966780456345" frameborder="0" scrolling="no" allow="fullscreen; clipboard-read; clipboard-write" allowfullscreen></iframe>

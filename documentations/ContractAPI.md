# ERC20

-   `approve(address spender, uint256 amount)`\

Set the amount of token `amount` allowed to be spent by `spender`.

# Elpis: Origin Asset

The NFT tokens in Elpis: Origin are derived from ERC721A. Common ERC721 APIs can be found at: https://docs.openzeppelin.com/contracts/4.x/erc721.

Here are some quick references, the `view` keyword indicates that this function is a read-only function.

-   `mintAsset(address _to) onlyOwner`\

Mint `_amount` number of assets and transfer them to address `to`. Server needs to keep track of the tokenId and generate the corresponding metadata file.

-   `totalSupply() view returns (uint256)`\

Return total number of token minted with token id `id`.

-   `balanceOf(address account, uint256 id) view returns (uint256)`\

Return the amount of token owned by `account` with token id `id`.

-   `tokenURI(uint256 tokenId) view returns (string memory)`\

Returns the link to the metadata of the `tokenId` token.

# Elpis: Origin Marketplace

Elpis: Origin provides a marketplace for users to trade their in-game assets using Elpis: Origin Token.

-   `setup(address _token, uint256 _tokenId, uint256 _price) returns (uint256)`\

Allow user to list their asset for sale, return the id recorded for this sale.\

`_token`: the Elpis: Origin Asset token address;\

`_tokenId`: the token id the user wishes to list for sale;\

`_price`: the number of the token the user wishes to sale for.

-   `trade(uint256 _saleId)`\

Purchase the listed asset with the id of `_saleId`.

-   `claim(uint256 _saleId)`\

After a successful sale, the seller will be able to claim the token the buyer paid for the asset with the id of `_saleId`.

# Elpis: Origin Vault

-   `distributeAsset(address  _newOwner, address  _nftaddress, uint256  _nftId) onlyOwner`\

Set the owner of a not owned NFT to a user, later the user can unlock the NFT itself.\

`_newOwner`: the owner of this NFT.\

`_nftaddress`: NFT contract address;\

`_nftId`: NFT corresponding token id.\

emit `DistributeAsset(_newOwner, _nftAddress, _nftId)`

-   `pay(uint256 _saleId)`\

Payment for certain item.\

`_saleId`: an id used for certain `SaleInfo`:\

```
struct  SaleInfo {
	address nftAddress;
	uint256 nftId;
	address tokenAddress;
	uint256 amount;
}
```

`nftAddress`: NFT contract address;\

`nftId`: NFT token id;\

`tokenAddress`: payment token address;\

`amount`: listed price;\

emit `Pay(saleId, nftAddress, nftId, tokenAddress, amount)`\

-   `lockToken(address _token, uint256 _amount)`\

Import token to game.\

`_token`: token contract address;\

`_amount`: the amount of token.\

emit `LockToken(msg.sender, _token, _amount)`

-   `unlockToken(address _token, uint256 _amount)`\

Export token to wallet which imported the token, can only be called by the token owner.\

`_token`: NFT contract address;\

`_amount`: the amount of token.\

emit `UnlockToken(msg.sender, _token, _amount)`

-   `lockAsset(address _nftAddress, uint256 _nftId)`\

Import NFT to game.\

`_nftAddress`: NFT contract address;\

`_nftId`: NFT corresponding token id.\

emit `LockAsset(msg.sender, _nftAddress, _nftId)`

-   `unlockAsset(address _nftAddress, uint256 _nftId)`\

Export NFT to wallet which imported the NFT, can only be called by the NFT owner.\

`_nftAddress`: NFT contract address;\

`_nftId`: NFT corresponding token id.\

emit `UnlockAsset(msg.sender, _nftAddress, _nftId)`

## NFT lifecycle:

https://miro.com/welcomeonboard/MjBRa3M4ekt3N29KZjMzNllUZmJsQjQzMXZYVGFwODVFUldhSTVHVUxFU0dnZ3FwTFI1TnRaRVB4OG8yd0VYYXwzNDU4NzY0NTU3OTA2OTkwNDEyfDI=?share_link_id=770583179389

## Purchase flowchart:

https://miro.com/welcomeonboard/aWViVmpEczlodlltVTg2aFpWVTN3V0xXdG5ZR3o1RndyTWJudlZCRmVwWFdEVUQ5ZEtzQ3Q0c0FqRktlcnZFM3wzNDU4NzY0NTU3OTA2OTkwNDEyfDI=?share_link_id=832261829043

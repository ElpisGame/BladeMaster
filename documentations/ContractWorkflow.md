# Elpis Origin Contract Workflow

---

## Purchase Process

###### _ElpisOriginVault.sol_

NFT purchases in the game are completed in two phases:

### Phase 1: sale info setup

When a NFT is minted, it will be transfered to the _ElpisOriginVault.sol_ contract waiting for the admin to setup its `SaleInfo`.

Contract admin need to call `setupSale(address _nftaddress, uint256 _nftId, address _token, uint256 _amount)` to complete the setup process. After successfully setup, a ID (`saleInfoId`) is granted to this `SaleInfo`, and it's auto-incremented by 1 (starting from 0).

### Phase 2: user purchase

1. Approve USDT by calling`USDT:approve(ElpisOriginVault, MAX_UINT256)`
2. Purchase the NFT by calling `pay(saleInfoId)`.

###### Reminder: it is also possible that users can send a transaction to the contract calling `pay(uint256 _saleInfoId)` without interacting with the game client or the server.

---

## Import/Export Processes and Mystery Box

###### _ElpisOriginVault.sol_

Both Elpis Origin's NFTs and sub-tokens can be exported from the game or imported to the game. Mystery box rewards are also distributed through the import/export process.

### Import

Users can import any NFTs to this contract (even if it is not from Elpis Origin) .

1. Approve the NFT by calling `NFT:approve(ElpisOriginVault, tokenId)`
2. Lock the NFT by calling `lockAsset(address _nftAddress, uint256 _nftId)`

### Export

Only the user which imported the NFT can export the exact same NFT by calling `unlockAsset(address _nftAddress, uint256 _nftId)`.

### Mystery Box rewards distribution

When a user is rewarded with a NFT from a Mystery Box, the admin needs to import the NFT for the user by calling `distributeAsset(address _newOwner, address _nftaddress, uint256 _nftId)`, so that this NFT's owner will be set to the user's address.
import { ethers } from "hardhat";
import { ElpisOriginAsset721A__factory } from "../typechain-types";

const isMainnet = false;

const MAINNET_MINTER = "0x8DCa84A08e7E585D7DC5b7079D53fd3BBFb07c65";
const MAINNET_VAULT_ADDRESS = "0xf2E2628997DA78AFf2a7692810F786b4Fe4E1811";
const MAINNET_NFT_NAME = "ELPIS ORIGIN CHARACTER";
const MAINNET_NFT_SYMBOL = "ELOC";
const MAINNET_TOKEN_URI =
    "https://assets.elpisgame.io/nfts/origin/nft_{id}.json";

const TESTNET_MINTER = "0x9Ac48F8C16eB094B9432aE7FdDa7002Ef611d096";
const TESTNET_VAULT_ADDRESS = "0xBe27f7443f8F10486a3cA50711392b3787f88cf8";
const TESTNET_NFT_NAME = "NFT Name";
const TESTNET_NFT_SYMBOL = "NFT Symbol";
const TESTNET_TOKEN_URI =
    "https://assets-test.elpisgame.io/nfts/origin/nft_{id}.json";

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log("deployerAddr :", deployerAddr);

    let minter;
    let vaultAddress;
    let nftName;
    let nftSymbol;
    let tokenURI;
    if (isMainnet) {
        minter = MAINNET_MINTER;
        vaultAddress = MAINNET_VAULT_ADDRESS;
        nftName = MAINNET_NFT_NAME;
        nftSymbol = MAINNET_NFT_SYMBOL;
        tokenURI = MAINNET_TOKEN_URI;
    } else {
        minter = TESTNET_MINTER;
        vaultAddress = TESTNET_VAULT_ADDRESS;
        nftName = TESTNET_NFT_NAME;
        nftSymbol = TESTNET_NFT_SYMBOL;
        tokenURI = TESTNET_TOKEN_URI;
    }

    let nftContract = await new ElpisOriginAsset721A__factory(deployer).deploy(
        minter,
        vaultAddress,
        nftName,
        nftSymbol,
        tokenURI
    );
    let nftAddress = await nftContract.getAddress();
    await nftContract.waitForDeployment();
    console.log("New nft address: ", nftAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

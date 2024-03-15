import { ethers } from "hardhat";
import { ElpisOriginAsset721A__factory } from "../typechain-types";

const MINTER = "0x9Ac48F8C16eB094B9432aE7FdDa7002Ef611d096";
const VAULT_ADDRESS = "0xBe27f7443f8F10486a3cA50711392b3787f88cf8";
const TOKEN_URI = "https://assets-test.elpisgame.io/nfts/origin/nft_{id}.json";
const NAME = "NFT Name";
const SYMBOL = "NFT Symbol";

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log("deployerAddr :", deployerAddr);

    let nftContract = await new ElpisOriginAsset721A__factory(deployer).deploy(
        MINTER,
        VAULT_ADDRESS,
        NAME,
        SYMBOL,
        TOKEN_URI
    );
    let nftAddress = await nftContract.getAddress();
    await nftContract.waitForDeployment();
    console.log("New nft address: ", nftAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

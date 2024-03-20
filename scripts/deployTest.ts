import { ethers } from "hardhat";
import {
    ElpisOriginAsset721A__factory,
    FakeUSDT__factory,
} from "../typechain-types";

const vaultProxyAddress = "0x6d448B19B0F0414DFC7f64eC29d012847C8A19F1";

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log("deployerAddr :", deployerAddr);

    let elpisAsset = await new ElpisOriginAsset721A__factory(deployer).deploy(
        deployerAddr,
        vaultProxyAddress,
        "Test Name",
        "Test Symbol",
        "https://assets-test.elpisgame.io/nfts/origin/nft_{id}.json"
    );
    await elpisAsset.mintAssetBatch(vaultProxyAddress, 10);
    console.log("Elpis Asset address: ", await elpisAsset.getAddress());

    let fUSDT = await new FakeUSDT__factory(deployer).deploy();
    console.log("fUSDT address: ", await fUSDT.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

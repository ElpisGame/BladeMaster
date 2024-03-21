import { ethers } from "hardhat";
import { ElpisOriginVault__factory } from "../typechain-types";

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log("deployerAddr :", deployerAddr);

    let vaultImplementation = await new ElpisOriginVault__factory(
        deployer
    ).deploy();
    let vaultImpAddress = await vaultImplementation.getAddress();
    await vaultImplementation.waitForDeployment();
    console.log("New vault implementation address: ", vaultImpAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

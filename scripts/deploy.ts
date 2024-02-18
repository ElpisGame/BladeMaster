import { ethers } from "hardhat";
import {
    ElpisOriginAsset721A,
    ElpisOriginAsset721A__factory,
    ElpisOriginMarket,
    ElpisOriginMarket__factory,
    ElpisOriginVault,
    ElpisOriginVault__factory,
    ElpisOriginSubToken,
    ElpisOriginSubToken__factory,
    // TransparentUpgradeableProxy,
    // TransparentUpgradeableProxy__factory,
    ElpisOriginProxy__factory,
    ProxyAdmin,
    ProxyAdmin__factory,
    ProxyTest__factory,
} from "../typechain-types";

const testAccount = "0x9Ac48F8C16eB094B9432aE7FdDa7002Ef611d096";
const ELPIS_ASSET_ADDRESS = "0x6B8a176Ab8e37dF3542fb34030Be66229a1361da";

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log(deployerAddr);

    let vaultImplementation = await new ElpisOriginVault__factory(
        deployer
    ).deploy();
    let vaultImpAddress = await vaultImplementation.getAddress();
    await vaultImplementation.waitForDeployment();
    console.log("Vault implementation address: ", vaultImpAddress);

    let proxy = await new ElpisOriginProxy__factory(deployer).deploy(
        vaultImpAddress,
        deployerAddr,
        "0x"
    );
    await proxy.waitForDeployment();

    let vaultProxyAddress = await proxy.getAddress();
    let vaultProxyAdminAddress = await proxy.proxyAdmin();
    console.log("Vault proxy address: ", vaultProxyAddress);
    console.log("Vault proxy admin address: ", vaultProxyAdminAddress);
    let vaultProxy = ElpisOriginVault__factory.connect(
        vaultProxyAddress,
        deployer
    );
    await vaultProxy.initialize(deployerAddr, deployerAddr);

    // let proxyAdmin = ProxyAdmin__factory.connect(
    //     vaultProxyAdminAddress,
    //     deployer
    // );

    let elpisAsset = ElpisOriginAsset721A__factory.connect(
        ELPIS_ASSET_ADDRESS,
        deployer
    );
    await elpisAsset.mintAssetBatch(vaultProxyAddress, 10);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

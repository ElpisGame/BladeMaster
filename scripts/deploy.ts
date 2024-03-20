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
    ElpisOriginProxy__factory,
    ProxyAdmin,
    ProxyAdmin__factory,
    ProxyTest__factory,
} from "../typechain-types";

const isTesting = true;

let testNftAddress: string;
// new deployment
let generalAdmin: string;
let vaultOwner: string;

async function main() {
    const [deployer] = await ethers.getSigners();
    const deployerAddr = await deployer.getAddress();
    console.log("deployerAddr :", deployerAddr);

    if (isTesting) {
        testNftAddress = "0x6B8a176Ab8e37dF3542fb34030Be66229a1361da";
        generalAdmin = "0x9Ac48F8C16eB094B9432aE7FdDa7002Ef611d096";
        vaultOwner = "0x03A65893283C70beC8AC0F6b515Fc40042ce2091";
    } else {
        generalAdmin = "0x8DCa84A08e7E585D7DC5b7079D53fd3BBFb07c65";
        vaultOwner = "0x197F023713dF6aa83653167652826C689Ce6C90d";
    }

    let vaultImplementation = await new ElpisOriginVault__factory(
        deployer
    ).deploy();
    let vaultImpAddress = await vaultImplementation.getAddress();
    await vaultImplementation.waitForDeployment();
    console.log("Vault implementation address: ", vaultImpAddress);

    let proxy = await new ElpisOriginProxy__factory(deployer).deploy(
        vaultImpAddress,
        generalAdmin,
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
    await vaultProxy.initialize(generalAdmin, vaultOwner);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

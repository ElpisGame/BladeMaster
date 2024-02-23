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

const ELPIS_ASSET_ADDRESS = "0x6B8a176Ab8e37dF3542fb34030Be66229a1361da";

// new deployment
const GNOSIS_ACCOUNT = "0x8DCa84A08e7E585D7DC5b7079D53fd3BBFb07c65";
const VAULT_OWNER = "0x197F023713dF6aa83653167652826C689Ce6C90d";

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
    await vaultProxy.initialize(GNOSIS_ACCOUNT, VAULT_OWNER);

    // let proxyAdmin = ProxyAdmin__factory.connect(
    //     vaultProxyAdminAddress,
    //     deployer
    // );

    const isTesting = false;
    if (isTesting) {
        let elpisAsset = ElpisOriginAsset721A__factory.connect(
            ELPIS_ASSET_ADDRESS,
            deployer
        );
        await elpisAsset.mintAssetBatch(vaultProxyAddress, 10);
    } else {
        let elpisAsset = await new ElpisOriginAsset721A__factory(
            deployer
        ).deploy(
            GNOSIS_ACCOUNT,
            vaultProxyAddress,
            "ELPIS ORIGIN CHARACTER",
            "ELOC",
            "https://assets.elpisgame.io/nfts/origin/nft_{id}.json"
        );
        console.log("Elpis Asset address: ", await elpisAsset.getAddress());
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

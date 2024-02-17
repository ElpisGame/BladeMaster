import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, network, upgrades } from "hardhat";
import { Signer } from "ethers";

import {
    ElpisOriginAsset721A,
    ElpisOriginAsset721A__factory,
    ElpisOriginMarket,
    ElpisOriginMarket__factory,
    ElpisOriginValt,
    ElpisOriginValt__factory,
    ElpisOriginSubToken,
    ElpisOriginSubToken__factory,
    TransparentUpgradeableProxy,
    TransparentUpgradeableProxy__factory,
} from "../typechain-types";

const ONE_ETH = ethers.parseEther("1");
const TWO_ETH = ethers.parseEther("2");

describe("Elpis Origin", function () {
    let snapshotId: string;
    let deployer: Signer;
    let signer1: Signer;
    let deployerAddr: string;
    let signer1Addr: string;
    let randomAddress: string;

    let asset: ElpisOriginAsset721A;
    let token: ElpisOriginSubToken;
    let market: ElpisOriginMarket;
    let vault: ElpisOriginValt;
    let assetAddress: string;
    let tokenAddress: string;
    let marketAddress: string;
    let vaultAddress: string;

    const initialTokenId = 0;

    before(async function () {
        // setup signers for testing
        [deployer, signer1] = await ethers.getSigners();
        deployerAddr = await deployer.getAddress();
        signer1Addr = await signer1.getAddress();
        let randomWallet = ethers.Wallet.createRandom();
        randomAddress = randomWallet.address;

        // console.log(new ElpisOriginValt__factory());
        const ElpisOriginValtFactory = await ethers.getContractFactory(
            "ElpisOriginValt"
        );
        let vault = await upgrades.deployProxy(ElpisOriginValtFactory, [
            randomAddress,
            deployerAddr,
        ]);

        console.log(vault);
    });

    beforeEach(async () => {
        snapshotId = await network.provider.send("evm_snapshot", []);
    });

    afterEach(async () => {
        await network.provider.send("evm_revert", [snapshotId]);
    });

    describe("Asset", function () {
        it("Basic Functions", async function () {
            console.log("deployer: ", deployerAddr);
        });
    });
});

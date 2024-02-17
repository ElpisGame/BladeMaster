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
    ElpisOriginVault,
    ElpisOriginVault__factory,
    ElpisOriginSubToken,
    ElpisOriginSubToken__factory,
    TransparentUpgradeableProxy,
    TransparentUpgradeableProxy__factory,
    ProxyAdmin,
    ProxyAdmin__factory,
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

    let proxyAdmin: ProxyAdmin;

    let asset: ElpisOriginAsset721A;
    let token: ElpisOriginSubToken;
    let market: ElpisOriginMarket;
    // let vaultImplementation: ElpisOriginVault;
    let vaultProxy: ElpisOriginVault;
    let assetAddress: string;
    let tokenAddress: string;
    let marketAddress: string;
    // let vaultImpAddress: string;
    let vaultProxyAddress: string;

    const initialTokenId = 0;

    before(async function () {
        // setup signers for testing
        [deployer, signer1] = await ethers.getSigners();
        deployerAddr = await deployer.getAddress();
        signer1Addr = await signer1.getAddress();
        let randomWallet = ethers.Wallet.createRandom();
        randomAddress = randomWallet.address;

        // deploy all contracts
        token = await new ElpisOriginSubToken__factory(deployer).deploy(
            deployerAddr,
            "Fake USDT",
            "USDT"
        );
        tokenAddress = await token.getAddress();
        market = await new ElpisOriginMarket__factory(deployer).deploy();
        marketAddress = await market.getAddress();

        let vaultImplementation = await new ElpisOriginVault__factory(
            deployer
        ).deploy();
        let vaultImpAddress = await vaultImplementation.getAddress();
        let proxy = await new TransparentUpgradeableProxy__factory(
            deployer
        ).deploy(vaultImpAddress, deployerAddr, "0x");
        vaultProxyAddress = await proxy.getAddress();
        vaultProxy = ElpisOriginVault__factory.connect(
            vaultProxyAddress,
            deployer
        );
        await vaultProxy.initialize(randomAddress, deployerAddr);
        asset = await new ElpisOriginAsset721A__factory(deployer).deploy(
            deployerAddr,
            vaultProxyAddress,
            "Elpis NFT",
            "NFT",
            "Token-URI"
        );
        assetAddress = await asset.getAddress();

        // set approvals
        asset.setApprovalForAll(vaultProxyAddress, true);
        asset.setApprovalForAll(marketAddress, true);

        // mint one NFT
        await asset.mintAsset(deployerAddr, "");
        expect(await asset.ownerOf(initialTokenId)).to.be.equal(deployerAddr);
    });

    beforeEach(async () => {
        snapshotId = await network.provider.send("evm_snapshot", []);
    });

    afterEach(async () => {
        await network.provider.send("evm_revert", [snapshotId]);
    });

    describe("Asset", function () {
        it("Basic Functions", async function () {
            const initialBalance = await asset.balanceOf(deployerAddr);
            const nextTokenId = await asset.nextTokenId();

            // #region: tokenURI
            const testURI = "test URI";
            await asset.mintAsset(deployerAddr, testURI);
            expect(await asset.tokenURI(nextTokenId)).to.be.equal(testURI);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 1n
            );
            // update tokenURI
            const testURI2 = "test URI2";
            await expect(asset.updateUniqueTokenURI(nextTokenId, testURI2))
                .to.emit(asset, "MetadataUpdate")
                .withArgs(nextTokenId);
            expect(await asset.tokenURI(nextTokenId)).to.be.equal(testURI2);
            // #endregion

            // fail case: not minter role
            await expect(asset.connect(signer1).mintAsset(deployerAddr, "")).to
                .be.reverted;

            // #region: batch mint
            await asset.mintAssetBatch(deployerAddr, 4);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 5n
            );
            await asset.burn(initialBalance + 4n);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 4n
            );
            // #endregion

            // #region: access control
            const minterRole = ethers.keccak256(
                ethers.toUtf8Bytes("MINTER_ROLE")
            );
            const adminRole = ethers.keccak256(
                ethers.toUtf8Bytes("ADMIN_ROLE")
            );
            expect(await asset.hasRole(minterRole, deployerAddr)).to.be.true;
            expect(await asset.hasRole(adminRole, deployerAddr)).to.be.true;
            expect(await asset.hasRole(adminRole, vaultProxyAddress)).to.be
                .true;
            expect(await asset.hasRole(minterRole, signer1Addr)).to.be.false;
            await expect(asset.grantRole(minterRole, signer1Addr))
                .to.emit(asset, "RoleGranted")
                .withArgs(minterRole, signer1Addr, deployerAddr);
            expect(await asset.hasRole(minterRole, signer1Addr)).to.be.true;
            // #endregion
        });
    });

    describe("Market", function () {
        let saleId;
        it("List/buy", async function () {
            await market.list(assetAddress, 0, tokenAddress, ONE_ETH);
            saleId = await market.saleId();
            expect(await asset.balanceOf(marketAddress)).to.be.equal(1n);
            // console.log(await market.saleInfos(saleId));

            // step 1: approve token
            await token.approve(marketAddress, ethers.MaxUint256);
            // step 2: purchase
            await market.purchase(saleId);

            const auctionPeriod = 100n;
            await market.listForAuction(
                assetAddress,
                0,
                tokenAddress,
                ONE_ETH,
                auctionPeriod
            );
            saleId = await market.saleId();
            await market.bid(saleId, TWO_ETH);
            // fail case: claim before end time
            await expect(market.claim(saleId)).to.be.revertedWith(
                "ElpisOriginMarket: active auction"
            );
            await network.provider.send("evm_increaseTime", [
                Number(auctionPeriod),
            ]);
            await market.claim(saleId);
        });
    });

    describe("Vault", function () {
        it("Pay", async function () {
            // setup SaleInfo
            const nextTokenId = await asset.nextTokenId();
            const nextSaleId = await vaultProxy.saleInfoId();
            await asset.mintAsset(vaultProxyAddress, "");
            await vaultProxy.setupSale(
                assetAddress,
                nextTokenId,
                tokenAddress,
                ONE_ETH
            );

            // #region: pay method
            const initialBalance = await token.balanceOf(vaultProxyAddress);
            await token.approve(vaultProxyAddress, ethers.MaxUint256);
            await expect(vaultProxy.pay(nextSaleId))
                .to.emit(vaultProxy, "Pay")
                .withArgs(
                    nextSaleId,
                    assetAddress,
                    nextTokenId,
                    tokenAddress,
                    ONE_ETH,
                    deployerAddr
                );
            expect(await token.balanceOf(vaultProxyAddress)).to.be.equal(
                initialBalance + ONE_ETH
            );

            await vaultProxy.withdrawFund(
                tokenAddress,
                initialBalance + ONE_ETH
            );
            expect(await token.balanceOf(vaultProxyAddress)).to.be.equal(0n);
            // #endregion
        });

        it("Lock/unlock", async function () {
            const initialBalance = await asset.balanceOf(vaultProxyAddress);
            await token.approve(vaultProxyAddress, ethers.MaxUint256);

            // #region: token lock/unlock
            await expect(vaultProxy.lockToken(tokenAddress, ONE_ETH))
                .to.emit(vaultProxy, "LockToken")
                .withArgs(deployerAddr, tokenAddress, ONE_ETH);
            expect(await token.balanceOf(vaultProxyAddress)).to.be.equal(
                ONE_ETH
            );

            // fail case: withdraw exceeded amount
            await expect(
                vaultProxy.unlockToken(tokenAddress, TWO_ETH)
            ).to.be.revertedWith("ElpisOriginValt: exceed max amount");

            await expect(vaultProxy.unlockToken(tokenAddress, ONE_ETH))
                .to.emit(vaultProxy, "UnlockToken")
                .withArgs(deployerAddr, tokenAddress, ONE_ETH);
            expect(await token.balanceOf(vaultProxyAddress)).to.be.equal(0n);
            // #endregion

            // #region: asset lock/unlock
            await expect(vaultProxy.lockAsset(assetAddress, initialTokenId))
                .to.emit(vaultProxy, "LockAsset")
                .withArgs(deployerAddr, assetAddress, initialTokenId);
            expect(await asset.balanceOf(vaultProxyAddress)).to.be.equal(
                initialBalance + 1n
            );

            // fail case: unlock someone else's asset
            await expect(
                vaultProxy
                    .connect(signer1)
                    .unlockAsset(assetAddress, initialTokenId)
            ).to.be.revertedWith("ElpisOriginValt: not the owner");

            await expect(vaultProxy.unlockAsset(assetAddress, initialTokenId))
                .to.emit(vaultProxy, "UnlockAsset")
                .withArgs(deployerAddr, assetAddress, initialTokenId);
            expect(await asset.balanceOf(vaultProxyAddress)).to.be.equal(
                initialBalance
            );
            // #endregion
        });

        it("Asset distribution", async function () {
            const initialBalance = await asset.balanceOf(deployerAddr);
            const nextTokenId = await asset.nextTokenId();
            await asset.mintAsset(vaultProxyAddress, "");
            await expect(
                vaultProxy.distributeAsset(
                    deployerAddr,
                    assetAddress,
                    nextTokenId
                )
            )
                .to.emit(vaultProxy, "DistributeAsset")
                .withArgs(deployerAddr, assetAddress, nextTokenId);

            await expect(vaultProxy.unlockAsset(assetAddress, nextTokenId))
                .to.emit(vaultProxy, "UnlockAsset")
                .withArgs(deployerAddr, assetAddress, nextTokenId);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 1n
            );
        });
    });
});

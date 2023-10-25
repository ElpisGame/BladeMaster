import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
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
} from "../typechain-types";

const ONE_ETH = ethers.parseEther("1");
const TWO_ETH = ethers.parseEther("2");

describe("BladeMaster", function () {
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

    before(async function () {
        // setup signers for testing
        [deployer, signer1] = await ethers.getSigners();
        deployerAddr = await deployer.getAddress();
        signer1Addr = await signer1.getAddress();
        let randomWallet = ethers.Wallet.createRandom();
        randomAddress = randomWallet.address;

        // deploy all contracts
        asset = await new ElpisOriginAsset721A__factory(deployer).deploy(
            deployerAddr,
            "Elpis NFT",
            "NFT"
        );
        assetAddress = await asset.getAddress();
        token = await new ElpisOriginSubToken__factory(deployer).deploy(
            deployerAddr,
            "Fake USDT",
            "USDT"
        );
        tokenAddress = await token.getAddress();
        market = await new ElpisOriginMarket__factory(deployer).deploy();
        marketAddress = await market.getAddress();
        vault = await new ElpisOriginValt__factory(deployer).deploy(
            randomAddress
        );
        vaultAddress = await vault.getAddress();

        asset.setApprovalForAll(vaultAddress, true);
        asset.setApprovalForAll(marketAddress, true);
    });

    describe("Basic Functions", function () {
        const tokenId = 0;

        before(async function () {
            await asset.mintAsset(deployerAddr, "");
            expect(await asset.ownerOf(tokenId)).to.be.equal(deployerAddr);
        });

        it("Asset", async function () {
            const initialBalance = await asset.balanceOf(deployerAddr);
            const nextTokenId = await asset.nextTokenId();
            const testURI = "test URI";
            await asset.mintAsset(deployerAddr, testURI);
            expect(await asset.tokenURI(nextTokenId)).to.be.equal(testURI);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 1n
            );

            // fail case: not minter role
            await expect(asset.connect(signer1).mintAsset(deployerAddr, "")).to
                .be.reverted;

            // batch mint
            await asset.mintAssetBatch(deployerAddr, 4);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 5n
            );
            await asset.burn(initialBalance + 4n);
            expect(await asset.balanceOf(deployerAddr)).to.be.equal(
                initialBalance + 4n
            );

            // access control
            const minterRole = ethers.keccak256(
                ethers.toUtf8Bytes("MINTER_ROLE")
            );
            expect(await asset.hasRole(minterRole, deployerAddr)).to.be.true;
            expect(await asset.hasRole(minterRole, signer1Addr)).to.be.false;
            await expect(asset.grantRole(minterRole, signer1Addr))
                .to.emit(asset, "RoleGranted")
                .withArgs(minterRole, signer1Addr, deployerAddr);
            expect(await asset.hasRole(minterRole, signer1Addr)).to.be.true;
        });

        it("Vault", async function () {
            // #region: pay method
            await token.approve(vaultAddress, ethers.MaxUint256);
            expect(await token.balanceOf(vaultAddress)).to.be.equal(0);
            await expect(vault.pay(0, tokenAddress, ONE_ETH))
                .to.emit(vault, "Pay")
                .withArgs(0, tokenAddress, ONE_ETH);
            expect(await token.balanceOf(vaultAddress)).to.be.equal(ONE_ETH);
            // #endregion

            // #region: token lock/release
            await expect(vault.lockToken(tokenAddress, ONE_ETH))
                .to.emit(vault, "LockToken")
                .withArgs(deployerAddr, tokenAddress, ONE_ETH);
            expect(await token.balanceOf(vaultAddress)).to.be.equal(TWO_ETH);

            // fail case: withdraw exceeded amount
            await expect(
                vault.releaseToken(tokenAddress, TWO_ETH)
            ).to.be.revertedWith("ElpisOriginValt: exceed max amount");

            await expect(vault.releaseToken(tokenAddress, ONE_ETH))
                .to.emit(vault, "ReleaseToken")
                .withArgs(deployerAddr, tokenAddress, ONE_ETH);
            expect(await token.balanceOf(vaultAddress)).to.be.equal(ONE_ETH);
            // #endregion

            // #region: asset lock/release
            await expect(vault.lockAsset(assetAddress, tokenId))
                .to.emit(vault, "LockAsset")
                .withArgs(deployerAddr, assetAddress, tokenId);
            expect(await asset.balanceOf(vaultAddress)).to.be.equal(1);

            // fail case: release someone else's asset
            await expect(
                vault.connect(signer1).releaseAsset(assetAddress, tokenId)
            ).to.be.revertedWith("ElpisOriginValt: not the owner");

            await expect(vault.releaseAsset(assetAddress, tokenId))
                .to.emit(vault, "ReleaseAsset")
                .withArgs(ethers.ZeroAddress, assetAddress, tokenId);
            expect(await asset.balanceOf(vaultAddress)).to.be.equal(0);
            // #endregion
        });

        it("Market", async function () {});
    });
});

import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";

import {
    ElpisOriginAsset,
    ElpisOriginAsset__factory,
    ElpisOriginMarket,
    ElpisOriginMarket__factory,
} from "../typechain-types";

describe("BladeMaster", function () {
    let deployer: Signer;
    let deployerAddr: string;

    let asset: ElpisOriginAsset;
    let market: ElpisOriginMarket;

    before(async function () {
        [deployer] = await ethers.getSigners();
        deployerAddr = await deployer.getAddress();
        asset = await new ElpisOriginAsset__factory(deployer).deploy();
        market = await new ElpisOriginMarket__factory(deployer).deploy();

        asset.setApprovalForAll(await market.getAddress(), true);
    });

    describe("Deployment", function () {
        it("Should setup a new sale", async function () {
            await asset.mintAsset(deployerAddr, "test");
            await market.setup(await asset.getAddress(), 0, 0);
        });
    });
});

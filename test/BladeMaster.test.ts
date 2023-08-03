import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";

import {
    BladeMasterAsset,
    BladeMasterAsset__factory,
    BladeMasterMarket,
    BladeMasterMarket__factory,
} from "../typechain-types";

describe("BladeMaster", function () {
    let deployer: Signer;
    let deployerAddr: string;

    let asset: BladeMasterAsset;
    let market: BladeMasterMarket;

    before(async function () {
        [deployer] = await ethers.getSigners();
        deployerAddr = await deployer.getAddress();
        asset = await new BladeMasterAsset__factory(deployer).deploy();
        market = await new BladeMasterMarket__factory(deployer).deploy();

        asset.setApprovalForAll(await market.getAddress(), true);
    });

    describe("Deployment", function () {
        it("Should setup a new sale", async function () {
            await asset.mintAsset(deployerAddr, "test");
            await market.setup(await asset.getAddress(), 0, 0);
        });
    });
});

import { ethers, network } from "hardhat";

import { Test__factory } from "../typechain-types";

describe("Elpis Origin", function () {
    it("Basic Functions", async function () {
        let deployer;
        [deployer] = await ethers.getSigners();
        console.log(await deployer.getAddress());

        let a = 1,
            b = 2;
        const message = ethers.solidityPackedKeccak256(
            ["uint256", "uint256"],
            [a, b]
        );
        const signature = await deployer.signMessage(ethers.toBeArray(message));
        // if not using ethers js:
        // const msg1 = Buffer.concat([
        //     Buffer.from("\x19Ethereum Signed Message:\n32", "ascii"),
        //     Buffer.from(arrayify(message)),
        // ]);
        console.log(signature);

        let contract = await new Test__factory(deployer).deploy();
        console.log(">>Kec: ", await contract.kec(a, b));
        // console.log(await contract.verify(a, b, signature));

        console.log("verify1: ", await contract.verify(a, b, signature));
        console.log("verify2: ", await contract.verify2(message, signature));
    });
});

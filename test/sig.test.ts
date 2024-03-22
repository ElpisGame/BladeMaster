// import "dotenv/config";
import { ethers, network } from "hardhat";

import { Test__factory } from "../typechain-types";

describe("Elpis Origin", function () {
    it("Basic Functions", async function () {
        let deployer;
        [deployer] = await ethers.getSigners();
        console.log("Deployer address: ", await deployer.getAddress());
        const signer = new ethers.Wallet(
            process.env.SERVER_PRIVATE_KEY!,
            ethers.provider
        );
        console.log("Signer address: ", await signer.getAddress());

        const tx = await deployer.sendTransaction({
            to: await signer.getAddress(),
            value: ethers.parseUnits("1", "ether"),
        });

        let contract = await new Test__factory(deployer).deploy();

        // // if not using ethers js:
        // // const msg1 = Buffer.concat([
        // //     Buffer.from("\x19Ethereum Signed Message:\n32", "ascii"),
        // //     Buffer.from(arrayify(message)),
        // // ]);

        // console.log(">>Kec: ", await contract.kec(a, b));
        // // console.log(await contract.verify(a, b, signature));

        let salt = 1,
            addr = "0xF83f5B45ceA84a6497B7E9Ef3c83999Df6967d0E",
            id = 5,
            token = "0xfe3fc4e22e02C5AbdfAD6553f36Df2C982E64a06",
            amount = 100000000;
        const message3 = ethers.solidityPackedKeccak256(
            ["uint256", "address", "uint256", "address", "uint256"],
            [salt, addr, id, token, amount]
        );
        // console.log(">>Kec: ", await contract.kec2(addr, id, token, amount));
        const signature3 = await signer.signMessage(ethers.toBeArray(message3));
        console.log(
            "pack :",
            ethers.solidityPacked(
                ["uint256", "address", "uint256", "address", "uint256"],
                [salt, addr, id, token, amount]
            )
        );
        console.log("message :", message3);
        console.log("array: ", ethers.toBeArray(message3));
        console.log("signature :", signature3);
        console.log(
            "verify3: ",
            await contract
                .connect(signer)
                .verify3(salt, addr, id, token, amount, signature3)
        );
    });
});

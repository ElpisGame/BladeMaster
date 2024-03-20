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

        let addr = "0xf2E2628997DA78AFf2a7692810F786b4Fe4E1811",
            id = 1,
            token = "0xf2E2628997DA78AFf2a7692810F786b4Fe4E1811",
            amount = 100;
        const message3 = ethers.solidityPackedKeccak256(
            ["address", "uint256", "address", "uint256"],
            [addr, id, token, amount]
        );
        // console.log(">>Kec: ", await contract.kec2(addr, id, token, amount));
        const signature3 = await signer.signMessage(ethers.toBeArray(message3));
        console.log(
            "pack :",
            ethers.solidityPacked(
                ["address", "uint256", "address", "uint256"],
                [addr, id, token, amount]
            )
        );
        console.log("message :", message3);
        console.log("array: ", ethers.toBeArray(message3));
        console.log("signature :", signature3);
        console.log(
            "verify3: ",
            await contract
                .connect(signer)
                .verify3(addr, id, token, amount, signature3)
        );
    });
});

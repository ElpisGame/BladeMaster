import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    solidity: "0.8.19",
    networks: {
        hardhat: {},
        mumbai: {
            url: "https://polygon-mumbai.g.alchemy.com/v2/BSCzQY85ap-o5po_HdIQuUHQbnFQLNXS",
            accounts: [process.env.PRIVATE_KEY!],
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_KEY,
    },
};

export default config;

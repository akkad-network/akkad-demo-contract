import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    holesky: {
      url: `https://holesky.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    akkad: {
      url: "https://rpc-testnet.akkad.network",
      accounts: [`0x${process.env.AKKAD_PRIVATE_KEY}`],
    }
  },
  defaultNetwork: "holesky",
  etherscan: {
    apiKey: {
      holesky: process.env.ETHERSCAN_API_KEY || '',
      akkad: 'dum-api'
    },
    customChains: [
      {
        network: "akkad",
        chainId: 1000000,
        urls: {
          apiURL: "https://scan-testnet.akkad.network/api/",
          browserURL: "https://scan-testnet.akkad.network",
        },
      },
    ],
  },
};

export default config;
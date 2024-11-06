import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    holesky: {
      url: `https://eth-holesky.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [`0x${process.env.SEPOLIA_PRIVATE_KEY}`],
    },
    bsc: {
      url: `https://eth-bsc.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [`0x${process.env.SEPOLIA_PRIVATE_KEY}`],
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
      sepolia: process.env.ETHERSCAN_API_KEY || '',
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
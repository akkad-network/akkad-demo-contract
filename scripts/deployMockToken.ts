import { ethers } from "hardhat";
import * as fs from "fs";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const network = process.env.NETWORK;
  if (!network) {
    throw new Error("Network name is required");
  }

  const paramsPath = `./${network}_params.json`;
  if (!fs.existsSync(paramsPath)) {
    throw new Error(`Params file for ${network} not found`);
  }

  const params = JSON.parse(fs.readFileSync(paramsPath, "utf-8"));
  const tokenName = params.name;
  const tokenSymbol = params.symbol;

  console.log(`Deploying ${tokenName} (${tokenSymbol}) on ${network}...`);

  const [owner] = await ethers.getSigners();
  const MockERC20 = await ethers.getContractFactory("MockERC20");

  const gasLimit = 5_000_000;
  const maxPriorityFeePerGas = ethers.parseUnits("30", "gwei");
  const maxFeePerGas = ethers.parseUnits("50", "gwei");
  const contract = await MockERC20.deploy(tokenName, tokenSymbol, owner.address, {
    gasLimit,
    maxPriorityFeePerGas,
    maxFeePerGas,
  });
  await contract.waitForDeployment();

  console.log(`MockERC20 deployed to: ${contract.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
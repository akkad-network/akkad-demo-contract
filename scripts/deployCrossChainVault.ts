import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as path from "path";

dotenv.config();

async function main() {
  const network = (await ethers.provider.getNetwork()).name;

  // Load deployments.json and get token addresses for the current network
  const deploymentsPath = path.resolve(__dirname, "../deployments.json");
  const deploymentsData = JSON.parse(fs.readFileSync(deploymentsPath, "utf-8"));

  const tokenAddresses: any[] = deploymentsData[network]
    ? Object.values(deploymentsData[network])
    : [];

  if (tokenAddresses.length === 0) {
    console.error(`No token addresses found for network: ${network}`);
    process.exit(1);
  }

  const [owner] = await ethers.getSigners();
  const CrossChainVault = await ethers.getContractFactory("CrossChainVault");

  const gasLimit = 5_000_000;
  const maxPriorityFeePerGas = ethers.parseUnits("30", "gwei");
  const maxFeePerGas = ethers.parseUnits("50", "gwei");

  const crossChainVault = await CrossChainVault.deploy(
    tokenAddresses, // Pass array of token addresses
    {
      gasLimit,
      maxPriorityFeePerGas,
      maxFeePerGas,
    }
  );

  await crossChainVault.waitForDeployment();

  console.log(`CrossChainVault deployed to: ${crossChainVault.target}`);

  // Update deployments.json with the new CrossChainVault address
  deploymentsData[network] = {
    ...deploymentsData[network],
    CrossChainVault: crossChainVault.target,
  };
  fs.writeFileSync(deploymentsPath, JSON.stringify(deploymentsData, null, 2));

  console.log(`Deployment details saved to ${deploymentsPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
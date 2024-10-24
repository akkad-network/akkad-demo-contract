import { ethers } from "hardhat";
import * as dotenv from "dotenv"; // Import dotenv to load environment variables

dotenv.config(); // Load variables from .env file

async function main() {
  const [owner] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(owner.address);
  const network = await ethers.provider.getNetwork()
  console.log("🚀 ~ main ~ network:", network)
  console.log(`Owner balance: ${owner.address} ${ethers.formatEther(balance)} ETH`);

  const ABTCVault = await ethers.getContractFactory("ABTCVault");

  const gasLimit = 5_000_000;
  const maxPriorityFeePerGas = ethers.parseUnits("30", "gwei");
  const maxFeePerGas = ethers.parseUnits("50", "gwei");

  const abtcVault = await ABTCVault.deploy(
    {
      gasLimit,
      maxPriorityFeePerGas,
      maxFeePerGas,
    }
  );

  // Wait for the deployment to complete
  await abtcVault.waitForDeployment()
}

// Handle errors gracefully and exit the process if any occur
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
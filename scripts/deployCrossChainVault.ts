import { ethers } from "hardhat";
import * as dotenv from "dotenv"; // Import dotenv to load environment variables

dotenv.config(); // Load variables from .env file

async function main() {
  const [owner] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(owner.address);
  const network = await ethers.provider.getNetwork()
  console.log(`Owner balance: ${owner.address} ${ethers.formatEther(balance)} ETH`);

  const CrossChainVault = await ethers.getContractFactory("CrossChainVault");

  const gasLimit = 5_000_000;
  const maxPriorityFeePerGas = ethers.parseUnits("30", "gwei");
  const maxFeePerGas = ethers.parseUnits("50", "gwei");

  const crossChainVault = await CrossChainVault.deploy(
    "0xd44b02f1ab47750958dbdbe13489d37014c8ebd6",
    {
      gasLimit,
      maxPriorityFeePerGas,
      maxFeePerGas,
    }
  );

  // Wait for the deployment to complete
  await crossChainVault.waitForDeployment()
}

// Handle errors gracefully and exit the process if any occur
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
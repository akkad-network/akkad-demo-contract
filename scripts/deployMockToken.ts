import { ethers } from "hardhat";
import * as dotenv from "dotenv"; // Import dotenv to load environment variables

dotenv.config(); // Load variables from .env file

async function main() {
  const [owner] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(owner.address);
  const network = await ethers.provider.getNetwork()
  console.log(`Owner balance: ${owner.address} ${ethers.formatEther(balance)} ETH`);

  const MockERC20 = await ethers.getContractFactory("MockERC20");

  const gasLimit = 5_000_000;
  const maxPriorityFeePerGas = ethers.parseUnits("30", "gwei");
  const maxFeePerGas = ethers.parseUnits("50", "gwei");

  const mockERC20 = await MockERC20.deploy(
    "Mock Holesky BTC",
    "HoBTC",
    owner.address,
    {
      gasLimit,
      maxPriorityFeePerGas,
      maxFeePerGas,
    }
  );

  // Wait for the deployment to complete
  await mockERC20.waitForDeployment()

}

// Handle errors gracefully and exit the process if any occur
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
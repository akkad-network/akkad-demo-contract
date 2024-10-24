import { ethers } from 'hardhat';
import * as dotenv from "dotenv"; // Import dotenv to load environment variables

dotenv.config(); // Load variables from .env file

async function main() {
    const singer = await ethers.provider.getSigner();

    const erc20 = await ethers.getContractAt("MockERC20", "0xd44b02f1ab47750958dbdbe13489d37014c8ebd6");
    const transaction = await erc20.mint(
        singer.address,
        ethers.parseUnits("10000", 18)
    );
    console.log("🚀 ~ main ~ transaction:", transaction)
    await transaction.wait()

}

// Handle errors gracefully and exit the process if any occur
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
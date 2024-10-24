import { ethers } from 'hardhat';
import * as dotenv from "dotenv"; // Import dotenv to load environment variables

dotenv.config(); // Load variables from .env file

async function main() {
    const singer = await ethers.provider.getSigner();
    const crossVaultAddress = '0x9813f09b21B87ff240E8c957def24a15Cec4d32E'
    const erc20Address = '0xd44b02f1ab47750958dbdbe13489d37014c8ebd6'
    const erc20 = await ethers.getContractAt("MockERC20", erc20Address);

    // const allowanceBefore = await erc20.allowance(singer.address, crossVaultAddress)
    // console.log("🚀 ~ main ~ allowanceBefore:", allowanceBefore)

    // const approveTrans = await erc20.approve(crossVaultAddress, ethers.parseUnits('100', 18))
    // const resApprove = await approveTrans.wait()
    // console.log("🚀 ~ main ~ resApprove:", resApprove)

    // const allowanceAfter = await erc20.allowance(singer.address, crossVaultAddress)
    // console.log("🚀 ~ main ~ allowanceAfter:", allowanceAfter)

    const crossVault = await ethers.getContractAt("CrossChainVault", crossVaultAddress);
    const balanceBefore = await crossVault.getDeposit(singer.address)
    console.log("🚀 ~ main ~ balanceBefore:", balanceBefore)

    const transaction = await crossVault.deposit(
        ethers.parseUnits("0.1", 18)
    );

    await transaction.wait()
    const balanceAfter = await crossVault.getDeposit(singer.address)
    console.log("🚀 ~ main ~ balanceAfter:", balanceAfter)

}

// Handle errors gracefully and exit the process if any occur
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
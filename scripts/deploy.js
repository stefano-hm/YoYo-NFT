import { ethers } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const YoYoNFT = await ethers.getContractFactory("YoYoNFT");

  const yoyo = await YoYoNFT.deploy(
    process.env.VRF_COORDINATOR,
    process.env.KEY_HASH,
    Number(process.env.SUBSCRIPTION_ID),
    200000,
    ethers.utils.parseEther("0.05"),
    100,
    "https://your-base-uri.com/metadata/"
  );

  await yoyo.deployed();
  console.log("YoYoNFT deployed to:", yoyo.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

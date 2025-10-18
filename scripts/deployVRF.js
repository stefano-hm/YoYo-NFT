const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying YoYoNFTWithVRF with account:", deployer.address);

  const NAME = "YoYoNFT";
  const SYMBOL = "YY";

  const VRF_COORDINATOR = process.env.VRF_COORDINATOR_SEPOLIA;
  const KEY_HASH = process.env.KEY_HASH_SEPOLIA;

  const SUBSCRIPTION_ID = hre.ethers.BigNumber.from(process.env.SUBSCRIPTION_ID_SEPOLIA);

  const MINT_FEE = hre.ethers.utils.parseEther("0.01");
  const MAX_SUPPLY = 100;

  const Factory = await hre.ethers.getContractFactory("YoYoNFTWithVRF");
  const nft = await Factory.deploy(
    NAME,
    SYMBOL,
    VRF_COORDINATOR,
    KEY_HASH,
    SUBSCRIPTION_ID,
    MINT_FEE,
    MAX_SUPPLY
  );

  await nft.deployed();
  console.log("✅ Deployed at:", nft.address);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});

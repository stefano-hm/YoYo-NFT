const hre = require("hardhat");

async function main() {
  const YoYoNFT = await hre.ethers.getContractFactory("YoYoNFT");
  const yoyo = await YoYoNFT.deploy();

  await yoyo.deployed();

  console.log("✅ YoYoNFT deployed to:", yoyo.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

const hre = require("hardhat");

async function main() {
  const [user] = await hre.ethers.getSigners();
  const contractAddress = "0x57752Bad494b5321E311b875c4E3666B161F062e";

  const nft = await hre.ethers.getContractAt("YoYoNFTWithVRF", contractAddress);

  console.log("Minting from:", user.address);
  const tx = await nft.requestRandomNFT(user.address, {
    value: hre.ethers.utils.parseEther("0.01"),
  });

  const receipt = await tx.wait();
  console.log("Mint requested!");
  console.log("Tx hash:", receipt.transactionHash);
  console.log("Wait ~1–2 minutes for Chainlink VRF to fulfill the request...");
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("YoYoNFTWithVRF - tokenomics", function () {
  let MockYoYoNFTWithVRF, nft, owner, addr1;
  const mintFee = ethers.utils.parseEther("0.01");
  const maxSupply = 3;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    MockYoYoNFTWithVRF = await ethers.getContractFactory("MockYoYoNFTWithVRF");
    nft = await MockYoYoNFTWithVRF.deploy(
      "YoYoNFT",
      "YY",
      owner.address,
      ethers.constants.HashZero,
      1,
      mintFee,
      maxSupply
    );
    await nft.deployed();
  });

  it("should revert if mint fee is insufficient", async function () {
    await expect(
      nft.connect(addr1).requestRandomNFT(addr1.address, { value: 0 })
    ).to.be.revertedWith("Insufficient mint fee");
  });

  it("should revert if max supply is reached", async function () {
    await nft.testSetReceiver(1, addr1.address);
    await nft.testFulfillRandomWords(1, [123]);

    await nft.testSetReceiver(2, addr1.address);
    await nft.testFulfillRandomWords(2, [456]);

    await nft.testSetReceiver(3, addr1.address);
    await nft.testFulfillRandomWords(3, [789]);

    await expect(nft.requestRandomNFT(addr1.address, { value: mintFee })).to.be.revertedWith(
      "Max supply reached"
    );
  });

  it("owner can withdraw collected fees", async function () {
    await owner.sendTransaction({
      to: nft.address,
      value: mintFee,
    });

    const before = await ethers.provider.getBalance(owner.address);
    const tx = await nft.connect(owner).withdraw();
    const receipt = await tx.wait();
    const gas = receipt.gasUsed.mul(receipt.effectiveGasPrice);
    const after = await ethers.provider.getBalance(owner.address);

    expect(after.add(gas)).to.be.gt(before);
  });

  it("should emit Withdrawn event when owner withdraws funds", async function () {
    await owner.sendTransaction({
      to: nft.address,
      value: ethers.utils.parseEther("0.01"),
    });

    const balance = await ethers.provider.getBalance(nft.address);
    expect(balance).to.equal(ethers.utils.parseEther("0.01"));

    await expect(nft.connect(owner).withdraw())
      .to.emit(nft, "Withdrawn")
      .withArgs(owner.address, ethers.utils.parseEther("0.01"));
  });
});

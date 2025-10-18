const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("YoYoNFTWithVRF - local test", function () {
  let MockYoYoNFTWithVRF, nft, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    MockYoYoNFTWithVRF = await ethers.getContractFactory("MockYoYoNFTWithVRF");
    nft = await MockYoYoNFTWithVRF.deploy(
      "YoYoNFT",
      "YY",
      owner.address,
      ethers.constants.HashZero,
      1,
      ethers.utils.parseEther("0.01"),
      10
    );
    await nft.deployed();
  });

  it("should simulate a random NFT mint without Chainlink", async function () {
    const requestId = 1;
    const randomNumber = Math.floor(Math.random() * 1000000);

    await nft.testSetReceiver(requestId, owner.address);
    await nft.testFulfillRandomWords(requestId, [randomNumber]);

    expect(await nft.ownerOf(1)).to.equal(owner.address);
    expect(await nft.tokenIdToURI(1)).to.equal("ipfs://random-" + randomNumber);
    expect(await nft.nextTokenId()).to.equal(2);
  });

  it("should emit NFTMinted event on mint", async function () {
    const requestId = 1;
    const randomNumber = 42;

    await nft.testSetReceiver(requestId, owner.address);

    await expect(nft.testFulfillRandomWords(requestId, [randomNumber]))
      .to.emit(nft, "NFTMinted")
      .withArgs(owner.address, 1, "ipfs://random-42");
  });
});

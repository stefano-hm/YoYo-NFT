const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("YoYoNFT (minimal test)", function () {
  let YoYoNFT, nft, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    YoYoNFT = await ethers.getContractFactory("YoYoNFT");
    nft = await YoYoNFT.deploy("YoYo", "YY", owner.address);
    await nft.deployed();
  });

  it("should have correct name and symbol", async function () {
    expect(await nft.name()).to.equal("YoYo");
    expect(await nft.symbol()).to.equal("YY");
  });

  it("owner can mint and tokenURI is set", async function () {
    const tx = await nft.mintTo(addr1.address, "ipfs://example-uri");
    await tx.wait();

    expect(await nft.nextTokenId()).to.equal(2);
    expect(await nft.ownerOf(1)).to.equal(addr1.address);
    expect(await nft.tokenURI(1)).to.equal("ipfs://example-uri");
  });

  it("non-owner cannot mint", async function () {
    await expect(nft.connect(addr1).mintTo(addr1.address, "ipfs://x")).to.be.revertedWith(
      "Ownable: caller is not the owner"
    );
  });

  it("should mint multiple NFTs and increment nextTokenId correctly", async function () {
    await nft.mintTo(addr1.address, "ipfs://uri1");
    await nft.mintTo(owner.address, "ipfs://uri2");
    await nft.mintTo(addr1.address, "ipfs://uri3");

    expect(await nft.nextTokenId()).to.equal(4);

    expect(await nft.ownerOf(1)).to.equal(addr1.address);
    expect(await nft.ownerOf(2)).to.equal(owner.address);
    expect(await nft.ownerOf(3)).to.equal(addr1.address);

    expect(await nft.tokenURI(1)).to.equal("ipfs://uri1");
    expect(await nft.tokenURI(2)).to.equal("ipfs://uri2");
    expect(await nft.tokenURI(3)).to.equal("ipfs://uri3");
  });
});

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YoYoNFT is ERC721URIStorage, Ownable {
  uint256 public nextTokenId;

  constructor(
    string memory name_,
    string memory symbol_,
    address initialOwner
  ) ERC721(name_, symbol_) Ownable() {
    nextTokenId = 1;
    _transferOwnership(initialOwner);
  }

  function mintTo(address to, string memory tokenURI_) external onlyOwner returns (uint256) {
    uint256 tokenId = nextTokenId;
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, tokenURI_);
    nextTokenId++;
    return tokenId;
  }
}

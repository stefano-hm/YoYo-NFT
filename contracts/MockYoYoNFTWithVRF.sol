// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./YoYoNFTWithVRF.sol";

contract MockYoYoNFTWithVRF is YoYoNFTWithVRF {
  constructor(
    string memory name_,
    string memory symbol_,
    address vrfCoordinator_,
    bytes32 keyHash_,
    uint256 subscriptionId_,
    uint256 mintFee_,
    uint256 maxSupply_
  )
    YoYoNFTWithVRF(name_, symbol_, vrfCoordinator_, keyHash_, subscriptionId_, mintFee_, maxSupply_)
  {}

  function testFulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external {
    fulfillRandomWords(requestId, randomWords);
  }

  function testSetReceiver(uint256 requestId, address receiver) external {
    requestIdToReceiver[requestId] = receiver;
  }
}

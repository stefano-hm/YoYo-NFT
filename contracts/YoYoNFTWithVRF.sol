// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFCoordinatorV2_5} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFCoordinatorV2_5.sol";

contract YoYoNFTWithVRF is ERC721URIStorage, VRFConsumerBaseV2Plus {
  uint256 public nextTokenId;
  VRFCoordinatorV2_5 private immutable COORDINATOR;

  bytes32 internal keyHash;
  uint256 internal subscriptionId;
  uint16 internal requestConfirmations;
  uint32 internal callbackGasLimit;

  uint256 public mintFee;
  uint256 public maxSupply;

  mapping(uint256 => address) public requestIdToReceiver;
  mapping(uint256 => string) public tokenIdToURI;

  event NFTRequested(address indexed requester, address indexed receiver, uint256 requestId);
  event NFTMinted(address indexed receiver, uint256 tokenId, string tokenURI);
  event Withdrawn(address indexed owner, uint256 amount);

  constructor(
    string memory name_,
    string memory symbol_,
    address vrfCoordinator_,
    bytes32 keyHash_,
    uint256 subscriptionId_,
    uint256 mintFee_,
    uint256 maxSupply_
  ) ERC721(name_, symbol_) VRFConsumerBaseV2Plus(vrfCoordinator_) {
    nextTokenId = 1;
    mintFee = mintFee_;
    maxSupply = maxSupply_;
    COORDINATOR = VRFCoordinatorV2_5(vrfCoordinator_);
    keyHash = keyHash_;
    subscriptionId = subscriptionId_;
    requestConfirmations = 3;
    callbackGasLimit = 100000;
  }

  function requestRandomNFT(address to) external payable returns (uint256) {
    require(nextTokenId <= maxSupply, "Max supply reached");
    require(msg.value >= mintFee, "Insufficient mint fee");

    VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
      keyHash: keyHash,
      subId: subscriptionId,
      requestConfirmations: requestConfirmations,
      callbackGasLimit: callbackGasLimit,
      numWords: 1,
      extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
    });

    uint256 requestId = COORDINATOR.requestRandomWords(request);
    requestIdToReceiver[requestId] = to;

    emit NFTRequested(msg.sender, to, requestId);
    return requestId;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
    uint256 tokenId = nextTokenId;
    require(tokenId <= maxSupply, "Max supply reached");
    nextTokenId++;

    address receiver = requestIdToReceiver[requestId];
    require(receiver != address(0), "Invalid receiver");

    string memory tokenURI_ = generateTokenURI(randomWords[0]);
    _safeMint(receiver, tokenId);
    _setTokenURI(tokenId, tokenURI_);
    tokenIdToURI[tokenId] = tokenURI_;

    emit NFTMinted(receiver, tokenId, tokenURI_);
  }

  function generateTokenURI(uint256 randomNumber) internal pure returns (string memory) {
    return string(abi.encodePacked("ipfs://random-", uint2str(randomNumber)));
  }

  function uint2str(uint256 _i) internal pure returns (string memory str) {
    if (_i == 0) return "0";
    uint256 j = _i;
    uint256 length;
    while (j != 0) {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0) {
      bstr[--k] = bytes1(uint8(48 + (j % 10)));
      j /= 10;
    }
    str = string(bstr);
  }

  function withdraw() external {
    require(msg.sender == owner(), "Only owner can withdraw");
    uint256 balance = address(this).balance;
    require(balance > 0, "Nothing to withdraw");
    payable(owner()).transfer(balance);
    emit Withdrawn(owner(), balance);
  }

  receive() external payable {}
  fallback() external payable {}
}

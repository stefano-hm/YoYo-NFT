// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract YoYoNFT is ERC721URIStorage, VRFConsumerBaseV2, Ownable {
  uint256 private _nextTokenId = 1;

  VRFCoordinatorV2Interface private immutable COORDINATOR;
  bytes32 private immutable keyHash;
  uint64 private immutable subscriptionId;
  uint32 private callbackGasLimit;
  uint16 private constant REQUEST_CONFIRMATIONS = 3;
  uint32 private constant NUM_WORDS = 1;

  uint256 public mintFee;
  uint256 public maxSupply;
  string public baseTokenURI;

  mapping(uint256 => address) public requestIdToSender;
  mapping(uint256 => string) public requestIdToTokenURI;

  struct Attributes {
    uint256 randomness;
    uint8 flexibility;
    uint8 balance;
    uint8 difficulty;
    uint8 rarity;
  }

  mapping(uint256 => Attributes) public tokenAttributes;

  event RandomnessRequested(uint256 indexed requestId, address indexed requester);
  event NFTMinted(address indexed to, uint256 indexed tokenId, uint256 randomness);

  constructor(
    address vrfCoordinator,
    bytes32 _keyHash,
    uint64 _subscriptionId,
    uint32 _callbackGasLimit,
    uint256 _mintFee,
    uint256 _maxSupply,
    string memory _baseTokenURI
  ) ERC721("YoYoNFT", "YOYO") VRFConsumerBaseV2(vrfCoordinator) Ownable(msg.sender) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    keyHash = _keyHash;
    subscriptionId = _subscriptionId;
    callbackGasLimit = _callbackGasLimit;
    mintFee = _mintFee;
    maxSupply = _maxSupply;
    baseTokenURI = _baseTokenURI;
  }

  function requestMint(
    string calldata optionalTokenURI
  ) external payable returns (uint256 requestId) {
    require(msg.value >= mintFee, "YoYoNFT: insufficient fee");
    require(totalSupply() < maxSupply, "YoYoNFT: max supply reached");

    requestId = COORDINATOR.requestRandomWords(
      keyHash,
      subscriptionId,
      REQUEST_CONFIRMATIONS,
      callbackGasLimit,
      NUM_WORDS
    );

    requestIdToSender[requestId] = msg.sender;
    if (bytes(optionalTokenURI).length > 0) {
      requestIdToTokenURI[requestId] = optionalTokenURI;
    }

    emit RandomnessRequested(requestId, msg.sender);
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
    address to = requestIdToSender[requestId];
    require(to != address(0), "YoYoNFT: request not found");

    uint256 randomness = randomWords[0];

    uint256 tokenId = _nextTokenId++;
    require(tokenId <= maxSupply, "YoYoNFT: supply exceeded");

    _safeMint(to, tokenId);

    if (bytes(requestIdToTokenURI[requestId]).length > 0) {
      _setTokenURI(tokenId, requestIdToTokenURI[requestId]);
      delete requestIdToTokenURI[requestId];
    }

    Attributes memory attr;
    attr.randomness = randomness;
    attr.flexibility = uint8(uint256(keccak256(abi.encode(randomness, "FLEX"))) % 100);
    attr.balance = uint8(uint256(keccak256(abi.encode(randomness, "BAL"))) % 100);
    attr.difficulty = uint8(uint256(keccak256(abi.encode(randomness, "DIFF"))) % 100);

    uint256 rarityRand = uint256(keccak256(abi.encode(randomness, "RAR"))) % 1000;
    if (rarityRand < 600) attr.rarity = 1;
    else if (rarityRand < 850) attr.rarity = 2;
    else if (rarityRand < 950) attr.rarity = 3;
    else if (rarityRand < 990) attr.rarity = 4;
    else attr.rarity = 5;

    tokenAttributes[tokenId] = attr;

    delete requestIdToSender[requestId];

    emit NFTMinted(to, tokenId, randomness);
  }

  function totalSupply() public view returns (uint256) {
    return _nextTokenId - 1;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_ownerOf(tokenId) != address(0), "YoYoNFT: nonexistent token");
    string memory specific = super.tokenURI(tokenId);
    if (bytes(specific).length > 0) {
      return specific;
    }
    return string(abi.encodePacked(baseTokenURI, _toString(tokenId)));
  }

  function _baseURI() internal view override returns (string memory) {
    return baseTokenURI;
  }

  function setMintFee(uint256 f) external onlyOwner {
    mintFee = f;
  }
  function setMaxSupply(uint256 s) external onlyOwner {
    require(s >= totalSupply());
    maxSupply = s;
  }
  function setBaseURI(string calldata u) external onlyOwner {
    baseTokenURI = u;
  }
  function setCallbackGasLimit(uint32 gl) external onlyOwner {
    callbackGasLimit = gl;
  }

  function withdraw(address payable to) external onlyOwner {
    uint256 bal = address(this).balance;
    require(bal > 0, "YoYoNFT: zero balance");
    (bool ok, ) = to.call{value: bal}("");
    require(ok, "withdraw failed");
  }

  function _toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  receive() external payable {}
  fallback() external payable {}
}

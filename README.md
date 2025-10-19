# YoYoNFT – Randomized NFT Collection using Chainlink VRF

YoYoNFT is an Ethereum-based NFT collection that integrates **Chainlink VRF (Verifiable Random Function)** to ensure that each minted NFT is assigned a **truly random and verifiable metadata**.  
The project also includes a **mock version** and a **local test suite** for full reproducibility in Hardhat.

---

## Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Technical Choices](#-technical-choices)
- [Smart Contracts](#-smart-contracts)
- [Setup & Installation](#-setup--installation)
- [Running Tests](#-running-tests)
- [Deployment](#-deployment)
- [Minting NFTs](#-minting-nfts)
- [License](#-license)

---

## Overview

The YoYoNFT project demonstrates how to build an **ERC-721 NFT collection** where each token’s metadata is determined by **on-chain randomness** through **Chainlink VRF v2.5**.  
This guarantees that no party — not even the contract owner — can manipulate the NFT traits.

It includes two main contracts:

1. **YoYoNFT.sol** → A minimal, classic ERC721 with owner-controlled minting.  
2. **YoYoNFTWithVRF.sol** → An extended version using Chainlink VRF for random NFT generation, mint fees, and max supply logic.

---

## Architecture

   ```bash
   contracts/
├─ YoYoNFT.sol
├─ YoYoNFTWithVRF.sol
└─ MockYoYoWithVRF.sol

   test/
├─ YoYoNFT.test.js
├─ YoYoNFTWithVRF.test.js
└─ YoYoNFTWithVRF.tokenomics.test.js

   scripts/
├─ deployVRF.js
└─ mint.js

   ```

The project uses:
- **Hardhat** for local development and testing.
- **Ethers.js** for contract interactions.
- **Chainlink VRF v2.5** to request and fulfill randomness.
- **dotenv** for environment variable management.

---

## Technical Choices

| Area | Choice | Rationale |
|------|---------|------------|
| **Solidity version** | `^0.8.19` | Ensures modern syntax and safety checks for overflows. |
| **NFT standard** | `ERC721URIStorage` (OpenZeppelin) | Simplifies metadata management via `tokenURI`. |
| **Ownership** | `Ownable` (OpenZeppelin) | Restricts minting and withdrawals to the contract owner. |
| **Randomness** | `VRFConsumerBaseV2Plus` + `VRFCoordinatorV2_5` | Integrates latest Chainlink VRF for secure random number generation. |
| **Testing** | Hardhat + Chai | Provides isolated, reproducible tests for minting, tokenomics, and VRF logic. |
| **Mocking** | `MockYoYoNFTWithVRF` | Enables local testing of `fulfillRandomWords` without Chainlink network. |
| **Tokenomics** | `mintFee` + `maxSupply` + `withdraw()` | Adds economic parameters and withdrawal logic for collected ETH. |

---

## Smart Contracts Summary

### `YoYoNFT.sol`
A basic ERC721 implementation allowing the owner to mint NFTs and set their metadata.

- **Functions:**
  - `mintTo(address to, string memory tokenURI)`
  - `nextTokenId()` getter
- **Usage:** Ideal for manual minting and testing metadata setup.

### `YoYoNFTWithVRF.sol`
An advanced contract extending ERC721 with **Chainlink VRF integration**.

- **Core Features:**
  - Randomized metadata generation via `generateTokenURI()`
  - Fee-based minting (`mintFee`)
  - Max supply enforcement (`maxSupply`)
  - Withdraw function for owner to claim collected ETH
- **Events:**
  - `NFTRequested`
  - `NFTMinted`
  - `Withdrawn`

### `MockYoYoNFTWithVRF.sol`
Mock contract for local testing — allows direct calls to `fulfillRandomWords()` and setting of mock receivers.

---

## Setup & Installation

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/yoyo-nft.git
cd yoyo-nft
```

### 2. Install dependencies
```bash
npm install
```

### 3. Create a `.env` file
```bash
VRF_COORDINATOR_SEPOLIA=<address>
KEY_HASH_SEPOLIA=<keyHash>
SUBSCRIPTION_ID_SEPOLIA=<subscriptionId>
```

### 4. Compile contracts
```bash
npx hardhat compile
```

---

## Running Tests

Run the full test suite (mock + tokenomics + VRF simulation):
```bash
npx hardhat test
```

This runs:
- ERC721 core logic
- Random fulfillment via mock
- Tokenomics (mint fees, supply, withdraws)

---

## Deployment

Deploy the contract to **Sepolia Testnet** using the script:
```bash
npx hardhat run scripts/deployVRF.js --network sepolia
```


After deployment, the contract was verified to be live at:

**Network:** Sepolia Testnet

**Contract address:** `0x57752Bad494b5321E311b875c4E3666B161F062e`

## Minting NFTs

To mint a random NFT (via Chainlink VRF):
```bash
npx hardhat run scripts/mint.js --network sepolia
```

Output example:
```bash
Minting from: 0xYourWalletAddress
Mint requested!
Tx hash: 0x...
Wait ~1–2 minutes for Chainlink VRF to fulfill the request...
```

---

## Notes
- Randomness requests require Chainlink VRF subscription funding (LINK).
- The `fulfillRandomWords` function is automatically called by Chainlink when randomness is ready.
- The generated metadata URI uses a simplified format:
```bash
ipfs://random-[randomNumber]
```

---

## License

This project is licensed under the MIT License.






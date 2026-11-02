# STANDING — On-Chain Reputation

> STANDING collects signed methods for verifiable reputation assertions, and a lookup layer answers who is trustworthy for lending, relaying or dispute resolution - no email required.

## What it does

STANDING collects signed methods for verifiable reputation assertions, and a lookup layer answers who is trustworthy for lending, relaying or dispute resolution - no email required. The entire lifecycle lives in one contract, every button in the UI calls a real function on it — there is no mock backend.

## Contract

| | |
|---|---|
| File | `contracts/OnChainReputation.sol` |
| Contract name | `OnChainReputation` (inherits `ReentrancyGuard, Ownable`) |
| Solidity | `^0.8.20` |
| State functions | 4 (of which 0 payable) |
| Deployed (mainnet 677) | not yet deployed — placeholder `0x000…000` |

### Function surface

| Function | Type | Returns |
|---|---|---|
| `owner` | view | address |
| `createProfile` | write | result / revert |
| `rateUser` | write | result / revert |
| `getProfile` | view | uint256 score, uint256 totalRatings, bool active |

### Events

| Event | Signature |
|---|---|
| `OwnershipTransferred` | (address indexed previousOwner, address indexed newOwner) |
| `ProfileCreated` | (address indexed user, uint256 initialScore) |
| `RatingGiven` | (address indexed rater, address indexed rated, uint256 score) |
| `RatingUpdated` | (address indexed rater, address indexed rated, uint256 oldScore, uint256 newScore) |

## Network

| | |
|---|---|
| Chain | BOT Chain Mainnet (chainId `677`) |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |
| Native currency | BOT (18 decimals) |
| Testnet | BOT Chain Testnet (chainId `968`) - `https://rpc.bohr.life` |

## Frontend

- **Wallet connection** - [Reown/AppKit](https://reown.com) (Web3Modal v2, inline modal, `subscribeAccount` / `subscribeNetwork`)
- **Web3 library** - ethers.js v6 (`BrowserProvider`, `Contract`, `parseEther`)
- **Animation** - GSAP 3 + ScrollTrigger (`expo.out` entrances, `prefers-reduced-motion` fallback renders content instantly)
- **Zero build step** - single `index.html`, CDN imports via ESM import map; no bundler, no framework runtime
- **Accessibility** - auto-generated `aria-label`s on all binary and form controls, focus-visible styles, button busy states

## Run it locally

```bash
git clone https://github.com/Henoch4/on-chain-reputation.git
cd on-chain-reputation
# open the frontend directly (no build step)
start frontend/index.html   # Windows
# or serve it if your browser blocks file:// modules:
npx serve frontend
```

> **Note** — contract addresses: the UI reads its deploy target from the `CA` constant at the top of the inline script. Until the contract is deployed to mainnet 677, the demo runs against the deterministic sample data built into the page; after deployment, set `CA['677']` to the real address and every button goes live.
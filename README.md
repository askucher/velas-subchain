# Velas Subchain Gateway Node



Velas Subchain is a lightweight gateway node that allows you to launch a dedicated "chainlet" on the Velas network. Each chainlet has its own chain ID and an ERC‑20 token defined directly in the genesis block. You can also allocate additional accounts and balances as you would in a Geth `genesis.json` file. Unlike traditional L1 solutions, Velas Subchain lets you implement smart contract–based consensus without needing to dive into Rust or Go development.

![My Image](https://raw.githubusercontent.com/askucher/velas-subchain/main/diagram.png)


## Features

- **Custom Chain ID**: Define your own chainlet with a unique `CHAINID`.
- **ERC‑20 Genesis Token**: Predeploy a standard OpenZeppelin ERC‑20 token with mint and burn capabilities.
- **Custom Allocations**: Add extra accounts and balances as in a typical `genesis.json`.
- **Smart Contract Consensus**: Leverage Solidity for consensus logic rather than low‑level languages.
- **One‑Click Installer**: Install dependencies, deploy the chainlet, and set up the Blockscout explorer via simple Bash scripts.

## Prerequisites

- Ubuntu server (18.04+)
- `curl`, `git`, `bash`
- Cloudflare setup (optional but recommended)

## Configuration

Copy the `.env.example` to `.env` and fill in the values:

```.env
MAIN=
TOTAL_SUPPLY=
NAME=
SYMBOL=
CHAINID=
GIT_BRANCH=
KEY_FILE=
PRIVATE_KEY=
OWNER_ADDRESS=
EXPLORER_DOMAIN=
PUBLIC_DDOS_PROTECTED_RPC=
LOGO_LIGHT_URL=
LOGO_DARK_URL=
ICON_LIGHT_URL=
ICON_DARK_URL=
EXPLORER_PLATE_BACKGROUND=
PUBLIC_RPC_URL=
````

| Variable                    | Description                                                        |
| --------------------------- | ------------------------------------------------------------------ |
| `MAIN`                      | Base directory for project artifacts (e.g., `/home/$USER`)         |
| `TOTAL_SUPPLY`              | Initial token supply in the smallest unit (e.g., wei)              |
| `NAME`                      | Human‑readable token name                                          |
| `SYMBOL`                    | Token ticker symbol (3–5 uppercase letters)                        |
| `CHAINID`                   | Ethereum‑compatible chain ID (e.g., Velas testnet/mainnet ID)      |
| `GIT_BRANCH`                | Git branch for your deployment/build workflow                      |
| `KEY_FILE`                  | Path to encrypted wallet file for signing (JSON keystore)          |
| `PRIVATE_KEY`               | Raw private key for the deployer (use secure vault best practices) |
| `OWNER_ADDRESS`             | Ethereum address corresponding to the private key                  |
| `EXPLORER_DOMAIN`           | Base URL for Blockscout explorer                                   |
| `PUBLIC_DDOS_PROTECTED_RPC` | DDoS‑protected RPC endpoint for dApps                              |
| `LOGO_LIGHT_URL`            | URL for the light‑mode logo (SVG recommended)                      |
| `LOGO_DARK_URL`             | URL for the dark‑mode logo (SVG recommended)                       |
| `ICON_LIGHT_URL`            | URL for the light‑mode app icon                                    |
| `ICON_DARK_URL`             | URL for the dark‑mode app icon                                     |
| `EXPLORER_PLATE_BACKGROUND` | CSS background property for the explorer banner                    |
| `PUBLIC_RPC_URL`            | Public RPC endpoint URL (e.g., `http://localhost:8545`)            |

## ERC-20 Genesis Token Example

Below is a sample OpenZeppelin ERC‑20 contract with mint and burn functions that will be used as the genesis token for your chainlet.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GenesisToken is ERC20, Ownable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.
     */
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
```

## Installation & Usage

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-org/velas-subchain.git
   cd velas-subchain
   ```

2. **Populate your environment**:

   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

3. **Run the helper script**:

   ```bash
   # Show available commands
   bash exec.sh help

   # Install Foundry, Rust, and other dependencies
   bash exec.sh install_all_deps

   # Deploy the gateway node and launch your chainlet
   bash exec.sh deploy

   # it should deploy all contracts and launch chainlet inside velas
   # it also starts the pm2 process of gateway node: 127.0.0.1:8545 . it should be covered with cloudflare https://yourdomain.com/rpc

   # Install the Blockscout explorer
   bash exec.sh install_explorer

   # it launched the blockcout explorer. But you feel free to use another one

   ```

If you encounter any issues, reach out for support:

* Telegram: [@consensus\_designer](http://t.me/consensus_designer)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

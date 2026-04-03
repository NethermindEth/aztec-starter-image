# Getting Started with Aztec & Noir

## What Is Aztec?

Aztec is a privacy-first Layer 2 on Ethereum. It lets you write smart contracts that support **both public and private state** — meaning you can build applications where sensitive data (balances, positions, counterparties) stays confidential while still benefiting from Ethereum's security.

**Noir** is the programming language you use to write these contracts. It has Rust-like syntax, and developers focus on writing contract logic — proof generation is handled automatically by the toolchain.

---

## Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Docker Desktop (macOS / Windows) or Docker Engine (Linux). |
| **A terminal** | Any terminal / command line. |

That's it. Everything else comes inside the Docker image.

---

## 1. Start the Local Aztec Network

We've prepared a Docker image with the full Aztec development environment pre-configured — local network, example contracts, CLI tools, and prefunded accounts.

```bash
docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter
```

Wait until you see:

```
[INFO] Aztec Server listening on port 8080
```

This gives you:
- A local Ethereum node (Anvil)
- Deployed Aztec L1 and L2 protocol contracts
- 3 prefunded test accounts (no setup needed for fees)
- PXE (Private Execution Environment) on port 8080
- Pre-loaded example contracts and CLI tools

---

## 2. Interact with the Network

Open a **new terminal** and connect to the running container:

```bash
docker exec -it aztec-starter bash
```

Now you're inside the container with all Aztec tools available.

### 2a. Import test accounts

```bash
aztec-wallet import-test-accounts
```

This gives you three prefunded accounts (`test0`, `test1`, `test2`).

### 2b. Create a wallet

```bash
aztec-wallet create-account -a my-wallet -f test0 --prover none
```

> **`--prover none`** skips proof generation on the local network, making everything much faster. On testnet/mainnet, proofs are required.

### 2c. Deploy a token contract

The image ships with example contracts. Deploy the Token contract:

```bash
aztec-wallet deploy TokenContractArtifact \
  --from accounts:test0 \
  --args accounts:test0 TestToken TST 18 \
  -a testtoken
```

### 2d. Mint tokens (public)

```bash
aztec-wallet send mint_to_public \
  --from accounts:test0 \
  --contract-address contracts:testtoken \
  --args accounts:test0 100
```

### 2e. Check your public balance

```bash
aztec-wallet simulate balance_of_public \
  --from test0 \
  --contract-address testtoken \
  --args accounts:test0
```

Expected output: `Simulation result: 100n`

### 2f. Move tokens to private state

This is where Aztec's privacy model shines — tokens move from publicly visible state to encrypted private state:

```bash
aztec-wallet send transfer_to_private \
  --from accounts:test0 \
  --contract-address testtoken \
  --args accounts:test0 25
```

Verify the split:

```bash
# Public balance (should be 75)
aztec-wallet simulate balance_of_public \
  --from test0 --contract-address testtoken --args accounts:test0

# Private balance (should be 25)
aztec-wallet simulate balance_of_private \
  --from test0 --contract-address testtoken --args accounts:test0
```

---

## 3. Writing a Noir Contract from Scratch

All development tools are available inside the container.

### 3a. Project structure

```
my-aztec-project/
├── contracts/
│   └── my_contract/
│       ├── src/
│       │   └── main.nr
│       └── Nargo.toml
```

### 3b. Nargo.toml

```toml
[package]
name = "my_contract"
type = "contract"
authors = [""]
compiler_version = ">=0.18.0"

[dependencies]
aztec = { git = "https://github.com/AztecProtocol/aztec-packages/", tag = "v4.1.3", directory = "noir-projects/aztec-nr/aztec" }
```

### 3c. Example: simple counter contract (main.nr)

```rust
use aztec::macros::aztec;

#[aztec]
pub contract Counter {
    use aztec::{
        macros::{functions::external, storage::storage},
        protocol::address::AztecAddress,
        state_vars::{Map, PublicMutable},
    };

    #[storage]
    struct Storage<Context> {
        counts: Map<AztecAddress, PublicMutable<Field, Context>, Context>,
    }

    #[external("public")]
    fn increment() {
        let sender = self.msg_sender();
        let current = self.storage.counts.at(sender).read();
        self.storage.counts.at(sender).write(current + 1);
    }

    #[external("utility")]
    unconstrained fn get_count(owner: AztecAddress) -> pub Field {
        self.storage.counts.at(owner).read()
    }
}
```

> For a full working example, see the [Counter Contract tutorial](https://docs.aztec.network/developers/docs/tutorials/contract_tutorials/counter_contract) or the [Token Contract tutorial](https://docs.aztec.network/developers/docs/tutorials/contract_tutorials/token_contract).

### 3d. Compile

```bash
aztec compile
```

> **Important:** Always use `aztec compile`, not `nargo compile`. The Aztec wrapper adds a required transpilation step that `nargo` alone does not perform.

### 3e. Generate TypeScript bindings (for JS/TS integration)

```bash
aztec codegen ./target/my_contract-MyContract.json -o src/artifacts
```

---

## 4. Deploying to Public Testnet

Once you've tested locally, you can deploy to the public testnet.

### Testnet details

| Field | Value |
|---|---|
| Node URL | `https://rpc.testnet.aztec-labs.com` |
| L1 Chain | Sepolia (Chain ID 11155111) |
| Block Explorers | [testnet.aztecscan.xyz](https://testnet.aztecscan.xyz), [aztecexplorer.xyz](https://aztecexplorer.xyz) |
| Faucet | [aztec-faucet.nethermind.io](https://aztec-faucet.nethermind.io) |

> **Important:** Your CLI version must match the testnet version. Check with `aztec --version` inside the container, and `aztec get-node-info -n https://rpc.testnet.aztec-labs.com` to compare. The pre-built image is pinned to the correct version.

### Step-by-step: deploy to testnet

All these commands run inside the container.

```bash
# 1. Set the testnet node URL
export AZTEC_NODE_URL=https://rpc.testnet.aztec-labs.com

# 2. Get the canonical Sponsored FPC address for this version
#    (this address is deterministic per version — do NOT hardcode it)
aztec get-canonical-sponsored-fpc-address
# Note the address printed, then:
export SPONSORED_FPC_ADDRESS=<address from above>

# 3. Register the sponsored fee-paying contract (no tokens needed)
aztec-wallet register-contract \
  -n $AZTEC_NODE_URL \
  --alias sponsoredfpc \
  $SPONSORED_FPC_ADDRESS SponsoredFPC \
  --salt 0

# 4. Create your account (register only — doesn't deploy yet)
aztec-wallet create-account \
  --register-only \
  -n $AZTEC_NODE_URL \
  --alias my-wallet

# 5. Deploy your account (fees are sponsored)
aztec-wallet deploy-account \
  -n $AZTEC_NODE_URL \
  --from my-wallet \
  --payment method=fpc-sponsored,fpc=contracts:sponsoredfpc \
  --register-class

# 6. Deploy a contract
aztec-wallet deploy \
  -n $AZTEC_NODE_URL \
  --from accounts:my-wallet \
  --payment method=fpc-sponsored,fpc=contracts:sponsoredfpc \
  --alias token \
  TokenContract \
  --args accounts:my-wallet Token TOK 18 --no-wait

# 7. Mint some private tokens
aztec-wallet send mint_to_private \
  -n $AZTEC_NODE_URL \
  --from accounts:my-wallet \
  --payment method=fpc-sponsored,fpc=contracts:sponsoredfpc \
  --contract-address token \
  --args accounts:my-wallet 10
```

> **Heads-up:** Testnet transactions are slower than local. The first transaction downloads proving keys. If you see a "Timeout awaiting isMined" message, the transaction is likely still processing — check the block explorer.

---

## 5. Key Concepts Cheat Sheet

| Concept | What It Means |
|---|---|
| **Private function** | Executes on the user's device. State is encrypted. Only the owner can decrypt. |
| **Public function** | Executes on the network (by the current block proposer). State is visible, like Ethereum. |
| **Hybrid state** | A single contract can have both private and public state — e.g. private balances with public total supply. |
| **PXE** | Private Execution Environment — runs on the client side, manages private state and proof generation. |
| **Aztec.nr** | The Noir library/framework that provides state management, annotations, and types for writing Aztec contracts. |
| **Noir** | The Rust-like language for writing zero-knowledge circuits and Aztec smart contracts. |
| **Fee Payment Contract (FPC)** | A contract that sponsors transaction fees. On testnet, a canonical sponsored FPC is available so you don't need tokens to get started. |

---

## 6. Useful Links

- **Aztec Docs:** https://docs.aztec.network
- **Quickstart:** https://docs.aztec.network/developers/getting_started_on_local_network
- **Noir Language Docs:** https://noir-lang.org/docs
- **Aztec Starter Repo:** https://github.com/AztecProtocol/aztec-starter
- **Aztec.nr (Smart Contract Framework):** https://github.com/AztecProtocol/aztec-nr
- **Block Explorers:** https://testnet.aztecscan.xyz, https://aztecexplorer.xyz
- **Faucet:** https://aztec-faucet.nethermind.io
- **Community Discord:** https://discord.gg/aztec

---

## Appendix: Native Install (without Docker)

If you prefer to install the Aztec toolchain directly on your machine instead of using the Docker image, this requires **Node.js v24** ([nvm](https://github.com/nvm-sh/nvm) recommended) and **Docker running** (the CLI uses it internally).

```bash
# Install the Aztec toolchain
VERSION=4.1.3 bash -i <(curl -sL https://install.aztec.network/4.1.3)

# Verify
aztec -V

# Start the local network
aztec start --local-network
```

> Check [docs.aztec.network](https://docs.aztec.network/developers/getting_started_on_local_network) for the latest version string.

This installs:
- **`aztec`** — compiles/tests contracts, launches infrastructure (local network, sequencer, prover, PXE)
- **`aztec-up`** — version manager (`aztec-up install <version>`, `aztec-up use <version>`, `aztec-up list`)
- **`aztec-wallet`** — CLI for interacting with the Aztec network

Once the local network is running, all the commands from Sections 2–4 above work the same way — just run them directly in your terminal instead of inside a Docker container.

---

*Last updated: April 2026. Always check [docs.aztec.network](https://docs.aztec.network) for the latest version numbers and network endpoints before running commands.*

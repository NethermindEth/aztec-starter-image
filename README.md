# Aztec Starter Docker Image

Pre-configured Aztec development environment with example contracts, CLI tools, and a local network.

## Build

```bash
# Build with latest Aztec version
docker build -t nethermind/aztec-starter .

# Build with a specific pinned version
docker build --build-arg AZTEC_VERSION=4.1.3 -t nethermind/aztec-starter .
```

## Usage

### Start the local network (default)

```bash
docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter
```

Wait for `Aztec Server listening on port 8080`, then open a second terminal:

```bash
# Connect to the running container
docker exec -it aztec-starter bash

# Inside the container — import test accounts and start interacting
aztec-wallet import-test-accounts
aztec-wallet create-account -a my-wallet -f test0 --prover none
aztec-wallet deploy TokenContractArtifact --from accounts:test0 --args accounts:test0 TestToken TST 18 -a testtoken
```

### Get a shell without starting the network

```bash
docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter shell
```

### Compile the hello world contract

Inside the container:

```bash
cd /app/contracts/hello_world
aztec compile
```

## What's inside

- **Full Aztec toolchain** — `aztec`, `aztec-wallet`, `aztec-nargo`, all on PATH
- **Local Ethereum node** (Anvil) — starts automatically
- **Deployed protocol contracts** — L1 and L2, ready to go
- **3 prefunded test accounts** — no fee setup needed
- **Example contracts** — in `/app/contracts/`

## Pinning the version

The `AZTEC_VERSION` build arg controls which base image to use. Always pin this to match the target network:

```bash
# Check current testnet version
aztec get-node-info -n https://rpc.testnet.aztec-labs.com

# Build with matching version
docker build --build-arg AZTEC_VERSION=4.1.3 -t nethermind/aztec-starter .
```

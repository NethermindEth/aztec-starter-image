# Aztec Starter Docker Image

Pre-configured Aztec development environment with example contracts, CLI tools, and a local network.

## Quick Start

```bash
docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter
```

Wait for `Aztec Server listening on port 8080`, then in a new terminal:

```bash
docker exec -it aztec-starter bash
```

For the full walkthrough — deploying contracts, minting tokens, private transfers, writing your own contracts, and deploying to testnet — see the **[Getting Started Guide](docs/aztec-noir-getting-started-simple.md)**.

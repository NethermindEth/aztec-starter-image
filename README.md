# Aztec Starter Docker Image

Pre-configured Aztec development environment with example contracts, CLI tools, and a local network.

## Quick Start

```bash
./run.sh
```

This starts the local Aztec network and drops you into a shell. Your current directory is mounted into the container, so any contract changes you make locally are immediately visible inside the container (and vice versa).

## Building the Image Locally

If you modify the `Dockerfile` or `docker/entrypoint.sh`, rebuild the image and use it:

```bash
docker build -t aztec-starter .
AZTEC_STARTER_IMAGE=aztec-starter ./run.sh
```

For the full walkthrough — deploying contracts, minting tokens, private transfers, writing your own contracts, and deploying to testnet — see the **[Getting Started Guide](docs/aztec-noir-getting-started-simple.md)**.

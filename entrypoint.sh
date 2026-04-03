#!/bin/bash
set -e

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       Aztec Development Environment              ║"
echo "  ║       Prepared by Nethermind                      ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""
echo "  Example contracts are in: /app/contracts/"
echo "  To compile:  cd /app/contracts/hello_world && aztec compile"
echo ""

# If the user passes a command, run it directly
if [ "$1" = "shell" ]; then
    echo "  Starting interactive shell..."
    echo "  Run 'aztec start --local-network --l1-rpc-urls http://localhost:8545' to start the network."
    echo ""
    exec /bin/bash
fi

# Default: start the local network
echo "  Starting Anvil (local L1)..."
anvil --silent --host 0.0.0.0 &
ANVIL_PID=$!

# Wait for Anvil to be ready
for i in $(seq 1 30); do
    if cast chain-id --rpc-url http://localhost:8545 >/dev/null 2>&1; then
        echo "  Anvil ready on port 8545"
        break
    fi
    sleep 1
done

echo ""
echo "  Starting Aztec node..."
echo "  (This may take a minute on first run)"
echo ""

# Ensure Anvil is stopped when the Aztec node exits
trap "kill $ANVIL_PID 2>/dev/null" EXIT

# Start the Aztec node pointing at the local Anvil instance
exec aztec start --local-network --l1-rpc-urls http://localhost:8545

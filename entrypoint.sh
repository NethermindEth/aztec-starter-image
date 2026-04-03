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
    echo "  Run 'aztec start --local-network' to start the network."
    echo ""
    exec /bin/bash
fi

# Default: start the local network
echo "  Starting local Aztec network..."
echo "  (This may take a minute on first run)"
echo ""

# Start the local network using the aztec CLI (available on PATH from the base image)
exec aztec start --local-network

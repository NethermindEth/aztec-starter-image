#!/bin/bash
set -e

LOG_FILE="/var/log/aztec.log"

{
# If the user passes "shell", skip network startup
if [ "${1:-}" = "shell" ]; then
    exec /bin/bash
fi

echo "Aztec Development Environment — Network Logs"
echo "============================================="
echo ""
echo "Services starting:"
echo "  - Anvil (local Ethereum L1 node) on port 8545"
echo "  - Aztec node (L2) on port 8080"
echo ""
echo "Log prefixes:"
echo "  sequencer:*   — block builder and transaction sequencing"
echo "  archiver:*    — L1-to-L2 data sync"
echo "  aztecjs:*     — client-side utilities"
echo "  simulator:*   — transaction simulation and execution"
echo "  ethereum:*    — L1 interaction"
echo ""
echo "Wait for 'Aztec Server listening on port 8080' before interacting."
echo "---------------------------------------------"
echo ""

# Start Anvil (local Ethereum L1 node)
anvil --silent --host 0.0.0.0 &
ANVIL_PID=$!

for i in $(seq 1 30); do
    if cast chain-id --rpc-url http://localhost:8545 >/dev/null 2>&1; then
        echo "Anvil ready on port 8545"
        break
    fi
    sleep 1
done

# Ensure Anvil is stopped when the Aztec node exits
trap "kill $ANVIL_PID 2>/dev/null" EXIT

# Start the Aztec node pointing at the local Anvil instance
exec aztec start --local-network --l1-rpc-urls http://localhost:8545
} 2>&1 | tee "$LOG_FILE"

#!/usr/bin/env bash
set -eu

# Start the Aztec starter container (if not already running) and drop into a shell.
# The current directory is mounted into the container so local changes are
# immediately visible inside (and vice versa).

IMAGE=${AZTEC_STARTER_IMAGE:-nethermind/aztec-starter}
CONTAINER_NAME="aztec-starter"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  # Remove stopped container with the same name if it exists.
  docker rm "$CONTAINER_NAME" 2>/dev/null || true

  echo ""
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║       Aztec Development Environment              ║"
  echo "  ║       Prepared by Nethermind                     ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo ""
  echo "  Starting a local Aztec network. This will:"
  echo "    1. Start Anvil (a local Ethereum L1 node)"
  echo "    2. Start the Aztec node (L2) on top of it"
  echo "    3. Drop you into a shell to interact with the network"
  echo ""
  echo "  Your local directory is mounted into the container,"
  echo "  so any contract changes you make are visible inside."
  echo ""
  echo "  Contracts:  /app/contracts/"
  echo "  Compile:    cd /app/contracts/hello_world && aztec compile"
  echo ""

  docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8080:8080 \
    -v "$PWD:/app" \
    "$IMAGE" > /dev/null

  echo "  Network starting in background (takes ~1 minute)."
  echo ""
  echo "  Logs:  tail -f /var/log/aztec.log  (or from host: docker logs -f $CONTAINER_NAME)"
  echo "  Guide: docs/aztec-noir-getting-started-simple.md"
  echo "  Stop:  exit the shell, then run: docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
  echo ""
fi

docker exec -it "$CONTAINER_NAME" bash

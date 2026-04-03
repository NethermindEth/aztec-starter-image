# Aztec Starter Image
# Pre-configured development environment for Aztec & Noir
#
# Usage:
#   docker build -t nethermind/aztec-starter .
#   docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter
#
# To get a shell instead of auto-starting the network:
#   docker run -it --name aztec-starter -p 8080:8080 nethermind/aztec-starter shell
#
# To connect to a running container:
#   docker exec -it aztec-starter bash

# Pin to a specific version for reproducibility.
# Update this to match the testnet version when needed.
ARG AZTEC_VERSION=4.1.3
FROM aztecprotocol/aztec:${AZTEC_VERSION}

# Copy the example contracts into the image
COPY contracts /app/contracts

# Copy the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set working directory to the app folder
WORKDIR /app

# Expose PXE port
EXPOSE 8080

# Default: start the local network
# Override with "shell" to get an interactive terminal
ENTRYPOINT ["/app/entrypoint.sh"]

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

# The base image doesn't put CLI tools on PATH — add wrapper scripts so that
# aztec and aztec-wallet work as expected from any shell.
RUN printf '#!/bin/sh\nexec node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js "$@"\n' > /usr/local/bin/aztec && \
    printf '#!/bin/sh\nexec node --no-warnings /usr/src/yarn-project/cli-wallet/dest/bin/index.js "$@"\n' > /usr/local/bin/aztec-wallet && \
    ln -s /usr/src/noir/noir-repo/target/release/nargo /usr/local/bin/nargo && \
    ln -s /usr/src/barretenberg/cpp/build/bin/bb-avm /usr/local/bin/bb && \
    chmod +x /usr/local/bin/aztec /usr/local/bin/aztec-wallet

# The base image strips the 'inquirer' package (interactive CLI dependency)
# since the node image doesn't need it. Install it with all transitive deps
# in a temp dir, then copy into the main node_modules.
RUN mkdir /tmp/inquirer-install && \
    cd /tmp/inquirer-install && \
    npm init -y --quiet && \
    npm install inquirer@10.1.8 --quiet && \
    cp -r node_modules/* /usr/src/yarn-project/node_modules/ && \
    rm -rf /tmp/inquirer-install

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

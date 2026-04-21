#!/bin/bash

echo "🚀 Starting OXToken Blockchain..."

cd /workspace/node

# Build if missing
if [ ! -f target/release/node-template ]; then
  echo "Building OXToken..."
  cargo build --release
fi

# Run your chain
./target/release/node-template \
--dev \
--name "OXToken Node" \
--ws-external \
--rpc-external \
--rpc-cors=all

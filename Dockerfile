FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------
# SYSTEM DEPENDENCIES
# ------------------------
RUN apt update && apt install -y \
    curl git build-essential clang pkg-config libssl-dev \
    ca-certificates libclang-dev llvm make cmake

# ------------------------
# NODE.JS (for contracts/frontend)
# ------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs

# ------------------------
# RUST
# ------------------------
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup target add wasm32-unknown-unknown

# ------------------------
# WORKSPACE
# ------------------------
WORKDIR /workspace

# Copy YOUR chain
COPY node /workspace/node

WORKDIR /workspace/node

# Cache deps
RUN cargo fetch

# Build OXToken chain
RUN cargo build --release

# ------------------------
# PORTS
# ------------------------
EXPOSE 9933 9944 30333

# ------------------------
# START
# ------------------------
CMD ["/start.sh"]

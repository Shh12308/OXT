FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ========================
# SYSTEM DEPENDENCIES
# ========================
RUN apt update && apt install -y \
    curl \
    git \
    build-essential \
    clang \
    pkg-config \
    libssl-dev \
    ca-certificates \
    libclang-dev \
    llvm \
    make \
    cmake \
    protobuf-compiler \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# ========================
# NODE.JS (for frontend / smart contracts tooling)
# ========================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs

# ========================
# RUST TOOLCHAIN (Substrate requirement)
# ========================
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default stable
RUN rustup update
RUN rustup target add wasm32-unknown-unknown
RUN rustup toolchain install nightly
RUN rustup component add rustfmt --toolchain nightly

# ========================
# BUILD SETTINGS (avoid CI crashes)
# ========================
ENV CARGO_BUILD_JOBS=2

# ========================
# WORKSPACE
# ========================
WORKDIR /workspace

# ========================
# CLONE SUBSTRATE TEMPLATE (stable base chain)
# ========================
RUN git clone --depth 1 \
    https://github.com/paritytech/substrate-node-template.git node

WORKDIR /workspace/node

# ========================
# BUILD CHAIN
# ========================
RUN cargo build --release --locked

# ========================
# START SCRIPT
# ========================
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ========================
# NETWORK PORTS
# ========================
EXPOSE 9933 9944 30333

# ========================
# START COMMAND
# ========================
CMD ["/start.sh"]

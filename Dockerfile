FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------
# SYSTEM DEPENDENCIES (FIXED FOR SUBSTRATE)
# ------------------------
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
    libudev-dev

# ------------------------
# NODE.JS (for frontend/contracts)
# ------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs

# ------------------------
# RUST SETUP
# ------------------------
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default stable
RUN rustup update
RUN rustup target add wasm32-unknown-unknown

# Reduce memory usage (IMPORTANT for CI)
ENV CARGO_BUILD_JOBS=2

# ------------------------
# WORKSPACE
# ------------------------
WORKDIR /workspace

# ✅ BEST PRACTICE: COPY LOCAL NODE (NO GIT CLONE)
COPY node /workspace/node

WORKDIR /workspace/node

# ------------------------
# BUILD
# ------------------------
RUN cargo fetch
RUN cargo build --release

# ------------------------
# START SCRIPT
# ------------------------
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ------------------------
# PORTS
# ------------------------
EXPOSE 9933 9944 30333

# ------------------------
# START
# ------------------------
CMD ["/start.sh"]

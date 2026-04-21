FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------
# SYSTEM DEPENDENCIES
# ------------------------
RUN apt update && apt install -y \
    curl git build-essential clang pkg-config libssl-dev \
    ca-certificates libclang-dev llvm make cmake

# ------------------------
# NODE.JS (optional but useful)
# ------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs

# ------------------------
# RUST SETUP (FIXED)
# ------------------------
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default stable
RUN rustup update
RUN rustup target add wasm32-unknown-unknown

# Reduce memory usage (VERY IMPORTANT)
ENV CARGO_BUILD_JOBS=2

# ------------------------
# WORKSPACE
# ------------------------
WORKDIR /workspace

# ⚠️ Use template instead of full substrate (MUCH smaller)
RUN git clone --depth 1 https://github.com/paritytech/substrate-node-template.git node

WORKDIR /workspace/node

# ------------------------
# CACHE + BUILD
# ------------------------
RUN cargo fetch
RUN cargo build --release

# ------------------------
# COPY START SCRIPT (YOU WERE MISSING THIS)
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

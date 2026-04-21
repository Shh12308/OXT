FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default stable
RUN rustup target add wasm32-unknown-unknown

ENV CARGO_BUILD_JOBS=2

WORKDIR /workspace

# 🔥 THIS NOW WORKS because node exists in repo
COPY node /workspace/node

WORKDIR /workspace/node

RUN cargo fetch
RUN cargo build --release

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 9933 9944 30333

CMD ["/start.sh"]

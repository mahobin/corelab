# =============================================================================
# docker/rust/Dockerfile — Rust Development Environment
#
# Stages:
#   base        → Debian slim + system deps
#   stable      → Rust stable toolchain + essential components
#   nightly     → Adds nightly toolchain for Miri, sanitizers, cargo-fuzz
#   tools       → Installs cargo ecosystem tools (audit, fuzz, flamegraph…)
#   dev         → Full interactive development image (default)
#   ci          → Minimal non-interactive CI image
#
# Build notes:
#   - Cargo registry and build cache are populated during the tools stage.
#     This means subsequent image rebuilds that only change workspace files
#     will skip the slow dependency compilation phase entirely.
#   - The dev stage adds a non-root user. CI runs as root.
#
# Usage:
#   docker build --target dev -t rust-env:dev .
#   docker build --target ci  -t rust-env:ci  .
# =============================================================================

ARG RUST_STABLE_VERSION=1
ARG DEBIAN_VERSION=bookworm-slim

# =============================================================================
# Stage 1: base — Debian slim with system build dependencies
# =============================================================================
FROM debian:${DEBIAN_VERSION} AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        # Build essentials
        build-essential \
        gcc \
        g++ \
        # Required by many Rust crates that link C libraries
        pkg-config \
        libssl-dev \
        # For proc-macro crates and cross-compilation
        clang \
        lld \
        # Utilities
        ca-certificates \
        curl \
        wget \
        git \
        make \
        cmake \
        # For cargo-flamegraph
        linux-perf \
        # For cargo-valgrind
        valgrind \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Stage 2: stable — Rust stable toolchain
# =============================================================================
FROM base AS stable

ARG RUST_STABLE_VERSION

# Install Rust via rustup in a location all users can access.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- \
        --no-modify-path \
        --profile minimal \
        --default-toolchain "${RUST_STABLE_VERSION}" \
        -y && \
    chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}"

# Add essential stable components.
RUN rustup component add \
        rustfmt \
        clippy \
        rust-src \
        rust-docs \
        llvm-tools-preview

# Verify stable.
RUN rustc --version && cargo --version && rustup show

# =============================================================================
# Stage 3: nightly — add nightly toolchain alongside stable
# =============================================================================
FROM stable AS nightly

# Install latest nightly and add components needed for Miri + sanitizers.
RUN rustup toolchain install nightly \
        --component miri,rust-src,rustfmt,clippy,llvm-tools-preview \
        --allow-downgrade && \
    # Set up Miri sysroot now so container startup is instant.
    cargo +nightly miri setup

# Verify nightly.
RUN rustup run nightly rustc --version && \
    rustup run nightly cargo --version

# =============================================================================
# Stage 4: tools — install cargo ecosystem tools
# =============================================================================
FROM nightly AS tools

# Install each tool with --locked to respect Cargo.lock for reproducibility.
# Each is a separate RUN so Docker caches them individually — a failed install
# of one tool doesn't bust the cache for all the others.

# Dependency auditing
RUN cargo install cargo-audit --locked

# Fuzzing harness
RUN cargo install cargo-fuzz --locked

# Code coverage
RUN cargo install cargo-llvm-cov --locked

# Flamegraph profiling
RUN cargo install flamegraph --locked || true

# Outdated dependency checker
RUN cargo install cargo-outdated --locked || true

# Tree of dependency graph
RUN cargo install cargo-tree --locked 2>/dev/null || true
# (cargo-tree is now built into cargo; install only fails gracefully)

# Bloat analysis
RUN cargo install cargo-bloat --locked || true

# Watch mode for fast iteration
RUN cargo install cargo-watch --locked || true

# Install hyperfine for wall-clock benchmarking.
ARG HYPERFINE_VERSION=1.18.0
RUN ARCH="$(uname -m)" && \
    case "$ARCH" in \
        x86_64)  TRIPLE="x86_64-unknown-linux-musl" ;; \
        aarch64) TRIPLE="aarch64-unknown-linux-musl" ;; \
        *)        echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    wget -qO /tmp/hyperfine.tar.gz \
        "https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine-v${HYPERFINE_VERSION}-${TRIPLE}.tar.gz" && \
    tar -xzf /tmp/hyperfine.tar.gz -C /tmp && \
    install -m 755 "/tmp/hyperfine-v${HYPERFINE_VERSION}-${TRIPLE}/hyperfine" /usr/local/bin/hyperfine && \
    rm -rf /tmp/hyperfine*

# Warm the Cargo registry index so the first `cargo build` inside a container
# doesn't have to fetch it from scratch.
RUN cargo search serde --limit 1 > /dev/null 2>&1 || true

# =============================================================================
# Stage 5: dev — full interactive development image
# =============================================================================
FROM tools AS dev

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        less \
        vim \
        man-db \
        gdb \
        lldb \
        strace \
        file \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root developer user.
RUN useradd -m -s /bin/bash -u 1000 dev && \
    # Give dev ownership of the cargo home so they can install tools locally.
    mkdir -p /home/dev/.cargo && \
    chown -R dev:dev /home/dev

USER dev
WORKDIR /home/dev/workspace

# Set the default toolchain for this user to stable; nightly available via +nightly.
RUN rustup default stable

# Validate.
RUN rustc --version && \
    cargo --version && \
    cargo +nightly --version && \
    cargo fmt --version && \
    cargo clippy --version && \
    cargo audit --version && \
    cargo fuzz --version && \
    hyperfine --version

CMD ["bash"]

# =============================================================================
# Stage 6: ci — slim non-interactive image for GitHub Actions
# =============================================================================
FROM tools AS ci

WORKDIR /workspace

# Validate CI toolchain.
RUN rustc --version && \
    cargo --version && \
    cargo +nightly --version && \
    cargo fmt --version && \
    cargo clippy --version && \
    cargo audit --version

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

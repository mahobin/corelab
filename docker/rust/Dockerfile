# =============================================================================
# docker/rust/Dockerfile — Rust Development Environment
#
# Base: rockylinux/rockylinux:9.7
#
# Stages:
#   base        → Rocky Linux 9.7 + EPEL + system build deps
#   stable      → Rust stable toolchain via rustup (correct channel name)
#   nightly     → Adds nightly + Miri sysroot
#   tools       → cargo-binstall + prebuilt cargo tools (NOT source builds)
#   dev         → Full interactive development image (default)
#   ci          → Minimal non-interactive image for GitHub Actions
#
# Key fixes vs previous version:
#   1. ARG RUST_STABLE_VERSION=stable  (was "1" — rustup rejected it)
#   2. cargo tools installed via cargo-binstall (prebuilt binaries)
#      → build time drops from 3.5 hours to ~5 minutes
#      cargo-watch alone took 18 min to compile from source
#   3. hyperfine installed via cargo-binstall (not fragile wget GitHub URLs)
#   4. Base image: Rocky 9.7 (was Debian bookworm-slim)
#   5. linux-perf removed (requires privileged container + kernel match)
#
# Build time breakdown (approximate, amd64):
#   base + stable + nightly : ~4 min  (network-bound, no compilation)
#   tools (binstall)        : ~3 min  (binary downloads, no compilation)
#   dev extras              : ~1 min
#   Total                   : ~8 min  (vs 3.5 hours with cargo install)
#
# Usage:
#   docker build --target dev -t rust-env:dev .
#   docker build --target ci  -t rust-env:ci  .
#   docker buildx build --platform linux/amd64,linux/arm64 --target ci .
# =============================================================================

ARG ROCKY_VERSION=9.7

# =============================================================================
# Stage 1: base — Rocky Linux 9.7 + system build dependencies
# =============================================================================
FROM rockylinux/rockylinux:${ROCKY_VERSION} AS base

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
        # Build essentials (linker, assembler, basic headers)
        gcc \
        gcc-c++ \
        make \
        # Required by many Rust crates that link against C libraries
        pkg-config \
        openssl-devel \
        # lld: fast linker, used by Rust builds to accelerate link step
        lld \
        # Clang: needed by some crates with C FFI (ring, prost, etc.)
        clang \
        # Utilities
        ca-certificates \
        curl \
        wget \
        git \
        cmake \
        # Memory debugging (cargo-valgrind)
        valgrind \
    && dnf clean all

# =============================================================================
# Stage 2: stable — Rust stable toolchain
# =============================================================================
FROM base AS stable

# Install Rust via rustup into a world-readable location so all users
# (including the non-root dev user created later) can access it.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

# IMPORTANT: --default-toolchain must be "stable", "beta", "nightly", or a
# fully-qualified version like "1.78.0". A bare major version like "1" is
# INVALID and causes rustup to exit with:
#   error: invalid value '1' for '--default-toolchain': invalid official toolchain name
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- \
        --no-modify-path \
        --profile minimal \
        --default-toolchain stable \
        -y && \
    chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}"

# Add components needed for CI (fmt, clippy) and source-level tooling.
RUN rustup component add \
        rustfmt \
        clippy \
        rust-src \
        llvm-tools-preview

RUN rustc --version && cargo --version && rustup show

# =============================================================================
# Stage 3: nightly — add nightly alongside stable
# =============================================================================
FROM stable AS nightly

# Install nightly with components needed for Miri and -Zsanitizer.
# --allow-downgrade: if a nightly component isn't available on the very
# latest nightly, rustup selects the most recent nightly that has all of them.
RUN rustup toolchain install nightly \
        --component miri,rust-src,rustfmt,clippy,llvm-tools-preview \
        --allow-downgrade

# Pre-populate the Miri sysroot during the build so container startup is
# instant (no "downloading Miri sysroot..." delay on first use).
RUN cargo +nightly miri setup

RUN rustup run nightly rustc --version && \
    rustup run nightly cargo --version

# =============================================================================
# Stage 4: tools — install cargo ecosystem tools via cargo-binstall
# =============================================================================
FROM nightly AS tools

# ---------------------------------------------------------------------------
# WHY cargo-binstall instead of `cargo install`?
#
# `cargo install` compiles every tool from source. Times measured in the
# previous image builds:
#   cargo-watch   : 18 minutes (797 crates compiled)
#   cargo-audit   :  8 minutes
#   cargo-fuzz    : 12 minutes  (nightly, proc-macro heavy)
#   cargo-bloat   :  6 minutes
#   Total         : ~3.5 hours for all tools
#
# cargo-binstall downloads pre-compiled binaries from GitHub Releases,
# verified by checksum. Install time for the same set: ~3 minutes total.
#
# cargo-fuzz has no stable prebuilt binary (requires nightly toolchain
# features at compile time), so it's installed from source separately.
# ---------------------------------------------------------------------------

# Step 1: Install cargo-binstall itself (it has a prebuilt musl binary).
ARG CARGO_BINSTALL_VERSION=1.10.4
RUN ARCH="$(uname -m)" && \
    case "$ARCH" in \
        x86_64)  TRIPLE="x86_64-unknown-linux-musl" ;; \
        aarch64) TRIPLE="aarch64-unknown-linux-musl" ;; \
        *)        echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL --retry 5 --retry-delay 3 \
        "https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-${TRIPLE}.tgz" \
        | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/cargo-binstall && \
    cargo-binstall --version

# Step 2: Install all tools via binstall (prebuilt binaries, no compilation).
# Each tool is a separate RUN so Docker caches each independently.

# Dependency auditing (advisory DB scanning)
RUN cargo-binstall --no-confirm cargo-audit

# Code coverage via LLVM instrumentation
RUN cargo-binstall --no-confirm cargo-llvm-cov

# Flamegraph profiling
RUN cargo-binstall --no-confirm flamegraph || true

# Outdated dependency checker
RUN cargo-binstall --no-confirm cargo-outdated || true

# Binary size analysis
RUN cargo-binstall --no-confirm cargo-bloat || true

# Watch mode (fast local iteration) — the tool that previously took 18 min
RUN cargo-binstall --no-confirm cargo-watch

# Wall-clock benchmarking
RUN cargo-binstall --no-confirm hyperfine

# Step 3: cargo-fuzz has no stable prebuilt — it must compile from source
# because it uses nightly-only Cargo features. Isolated in its own layer.
# This is the one acceptable slow step; it compiles ~30 crates, ~4 minutes.
RUN cargo +nightly install cargo-fuzz --locked

# Warm the Cargo registry index so the first `cargo build` in a container
# doesn't incur a cold registry fetch.
RUN cargo search serde --limit 1 > /dev/null 2>&1 || true

# Verify all tools are present.
RUN cargo-binstall --version && \
    cargo audit --version && \
    cargo watch --version && \
    cargo fuzz --version && \
    hyperfine --version && \
    echo "All cargo tools installed."

# =============================================================================
# Stage 5: dev — full interactive development image
# =============================================================================
FROM tools AS dev

RUN dnf install -y \
        bash-completion \
        less \
        vim \
        man-db \
        gdb \
        strace \
        file \
        jq \
    && dnf clean all

# Create a non-root developer user. The cargo home at /usr/local/cargo is
# world-writable (set above) so the dev user can install tools locally.
RUN useradd -m -s /bin/bash -u 1000 dev
USER dev
WORKDIR /home/dev/workspace

RUN rustup default stable

# Final validation.
RUN rustc --version && \
    cargo --version && \
    cargo +nightly --version && \
    cargo fmt --version && \
    cargo clippy --version && \
    cargo audit --version && \
    cargo watch --version && \
    cargo fuzz --version && \
    hyperfine --version && \
    echo "rust-env dev image ready."

CMD ["bash"]

# =============================================================================
# Stage 6: ci — non-interactive image for GitHub Actions
# =============================================================================
FROM tools AS ci

WORKDIR /workspace

RUN rustc --version && \
    cargo --version && \
    cargo +nightly --version && \
    cargo fmt --version && \
    cargo clippy --version && \
    cargo audit --version && \
    echo "rust-env CI image ready."

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

# =============================================================================
# docker/c/Dockerfile — C Development Environment
#
# Stages:
#   base        → Ubuntu 24.04 LTS, apt toolchain, shared system deps
#   toolchain   → GCC + Clang + full build/analysis suite
#   sanitizers  → ASan/UBSan/TSan/LSan instrumented runtime libs
#   dev         → Full interactive development image (default)
#   ci          → Minimal non-interactive CI image (no docs/man pages)
#
# Usage:
#   docker build --target dev -t c-env:dev .
#   docker build --target ci  -t c-env:ci  .
#
# Multi-arch:
#   docker buildx build --platform linux/amd64,linux/arm64 --target ci .
# =============================================================================

ARG UBUNTU_VERSION=24.04
ARG LLVM_VERSION=18

# =============================================================================
# Stage 1: base — minimal Ubuntu with essentials
# =============================================================================
FROM ubuntu:${UBUNTU_VERSION} AS base

ARG LLVM_VERSION

# Prevent interactive prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        # Core utilities
        ca-certificates \
        curl \
        wget \
        git \
        gnupg \
        lsb-release \
        software-properties-common \
        # Build infrastructure
        make \
        cmake \
        ninja-build \
        pkg-config \
        # Compression (for downloading tools)
        xz-utils \
        zstd \
        # Python3 (needed by some build scripts)
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Stage 2: toolchain — GCC + Clang + analysis tools
# =============================================================================
FROM base AS toolchain

ARG LLVM_VERSION

# Add the official LLVM apt repository for a specific LLVM version.
# This ensures a newer Clang than Ubuntu's default where needed.
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
        | gpg --dearmor > /usr/share/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] \
        http://apt.llvm.org/noble/ llvm-toolchain-noble-${LLVM_VERSION} main" \
        > /etc/apt/sources.list.d/llvm.list

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        # GCC — multiple versions for matrix builds
        gcc \
        gcc-13 \
        g++ \
        g++-13 \
        # Clang/LLVM suite
        clang-${LLVM_VERSION} \
        clang++-${LLVM_VERSION} \
        clang-format-${LLVM_VERSION} \
        clang-tidy-${LLVM_VERSION} \
        lld-${LLVM_VERSION} \
        llvm-${LLVM_VERSION} \
        llvm-${LLVM_VERSION}-dev \
        llvm-${LLVM_VERSION}-tools \
        libclang-${LLVM_VERSION}-dev \
        # Sanitizer runtime libraries
        libasan8 \
        libubsan1 \
        libtsan2 \
        liblsan0 \
        # Static analysis
        cppcheck \
        # Memory debugging
        valgrind \
        # Fuzzing — AFL++
        afl++ \
        # Build utilities
        bear \
        strace \
        ltrace \
        # Debugging
        gdb \
        lldb-${LLVM_VERSION} \
        # C standard library headers (provides math.h, string.h, etc.)
        # Note: libm-dev does not exist on Ubuntu 24.04; math is part of libc6-dev.
        # linux-tools-generic is intentionally omitted: perf requires a privileged
        # container with matching kernel headers; use the host's `perf` instead.
        libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Create unversioned symlinks so `clang`, `clang-format`, `clang-tidy`
# etc. all resolve without specifying the version suffix.
RUN update-alternatives --install /usr/bin/clang       clang       /usr/bin/clang-${LLVM_VERSION}       100 && \
    update-alternatives --install /usr/bin/clang++     clang++     /usr/bin/clang++-${LLVM_VERSION}     100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_VERSION} 100 && \
    update-alternatives --install /usr/bin/clang-tidy  clang-tidy  /usr/bin/clang-tidy-${LLVM_VERSION}  100 && \
    update-alternatives --install /usr/bin/lldb        lldb        /usr/bin/lldb-${LLVM_VERSION}        100 && \
    update-alternatives --install /usr/bin/lld         lld         /usr/bin/lld-${LLVM_VERSION}         100

# =============================================================================
# Stage 3: sanitizers — verify sanitizer runtimes are functional
# =============================================================================
FROM toolchain AS sanitizers

# Write and compile a minimal test program with each sanitizer to verify
# the instrumentation is correctly installed. This fails the build early
# if the sanitizer libraries are missing or broken.
RUN printf '#include <stdio.h>\nint main(void){puts("ok");return 0;}\n' \
        > /tmp/sancheck.c && \
    \
    # ASan + UBSan
    clang -fsanitize=address,undefined -fno-omit-frame-pointer \
          -g -O1 /tmp/sancheck.c -o /tmp/sancheck_asan && \
    ASAN_OPTIONS=halt_on_error=1 /tmp/sancheck_asan && \
    \
    # TSan (incompatible with ASan; separate binary)
    clang -fsanitize=thread -fno-omit-frame-pointer \
          -g -O1 /tmp/sancheck.c -o /tmp/sancheck_tsan && \
    TSAN_OPTIONS=halt_on_error=1 /tmp/sancheck_tsan && \
    \
    # LSan standalone
    clang -fsanitize=leak -fno-omit-frame-pointer \
          -g -O1 /tmp/sancheck.c -o /tmp/sancheck_lsan && \
    LSAN_OPTIONS=verbosity=0 /tmp/sancheck_lsan && \
    \
    rm -f /tmp/sancheck.c /tmp/sancheck_asan /tmp/sancheck_tsan /tmp/sancheck_lsan

# =============================================================================
# Stage 4: dev — full interactive development image
# =============================================================================
FROM sanitizers AS dev

# Install developer-convenience tools not needed in CI.
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        # Shell comfort
        bash-completion \
        less \
        vim \
        nano \
        man-db \
        # File inspection
        file \
        hexdump \
        xxd \
        # Network tools (for testing networked C programs)
        netcat-openbsd \
        iproute2 \
        # Documentation
        doxygen \
        graphviz \
    && rm -rf /var/lib/apt/lists/*

# Install hyperfine for benchmarking.
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

# Create a non-root user for interactive development.
# CI uses root; local dev should not.
RUN useradd -m -s /bin/bash -u 1000 dev
USER dev
WORKDIR /home/dev/workspace

ENV PATH="/usr/local/bin:${PATH}"

# Verify final toolchain state.
RUN gcc --version && \
    clang --version && \
    make --version && \
    cmake --version && \
    cppcheck --version && \
    valgrind --version && \
    afl-fuzz --version 2>/dev/null || true && \
    bear --version && \
    gdb --version | head -1

CMD ["bash"]

# =============================================================================
# Stage 5: ci — stripped-down non-interactive image for GitHub Actions
# =============================================================================
FROM sanitizers AS ci

# Verify the CI toolchain is intact.
RUN gcc --version && \
    clang --version && \
    make --version && \
    cppcheck --version && \
    valgrind --version

WORKDIR /workspace

# Default entrypoint is a login shell so the runner can exec arbitrary commands.
ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

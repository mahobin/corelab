# =============================================================================
# docker/c/Dockerfile — C Development Environment
#
# Base: rockylinux/rockylinux:9.7
#
# Stages:
#   base        → Rocky Linux 9.7 + EPEL + CRB + core system packages
#   toolchain   → GCC 13 + LLVM/Clang (from llvm-toolset) + compiler-rt
#   sanitizers  → Compile-time verification that all four sanitizers link
#   dev         → Full interactive development image (default target)
#   ci          → Minimal non-interactive image for GitHub Actions
#
# Why Rocky Linux 9.7?
#   - RHEL-compatible, enterprise-grade, long-term stable
#   - llvm-toolset in AppStream ships clang + compiler-rt together so
#     sanitizer runtimes (libclang_rt.asan-*.a etc.) are always present
#   - EPEL provides AFL++, cppcheck, valgrind, bear
#
# Key fixes vs previous Ubuntu version:
#   - libm-dev removed (doesn't exist; math.h lives in glibc-devel)
#   - linux-tools-generic removed (perf needs privileged + kernel match)
#   - compiler-rt explicitly installed → fixes libclang_rt.asan*.a errors
#   - hyperfine installed via cargo-binstall → no fragile GitHub wget URLs
#
# Usage:
#   docker build --target dev -t c-env:dev .
#   docker build --target ci  -t c-env:ci  .
#   docker buildx build --platform linux/amd64,linux/arm64 --target ci .
# =============================================================================

ARG ROCKY_VERSION=9.7

# =============================================================================
# Stage 1: base — Rocky Linux 9.7 with EPEL + CRB enabled
# =============================================================================
FROM rockylinux/rockylinux:${ROCKY_VERSION} AS base

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

# Enable EPEL (Extra Packages for Enterprise Linux) and CRB (CodeReady Linux
# Builder). EPEL provides AFL++, cppcheck, bear. CRB unlocks -devel packages.
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
        make \
        cmake \
        ninja-build \
        pkg-config \
        ca-certificates \
        curl \
        wget \
        git \
        xz \
        zstd \
        python3 \
        python3-pip \
    && dnf clean all

# =============================================================================
# Stage 2: toolchain — GCC + Clang + compiler-rt + analysis tools
# =============================================================================
FROM base AS toolchain

# ---------------------------------------------------------------------------
# Install llvm-toolset from Rocky 9 AppStream.
# This is the recommended source for clang on RHEL/Rocky because it ships
# compiler-rt (the sanitizer runtime library package) alongside clang.
# compiler-rt provides:
#   - libclang_rt.asan-x86_64.a   (AddressSanitizer)
#   - libclang_rt.tsan-x86_64.a   (ThreadSanitizer)
#   - libclang_rt.ubsan_*.a        (UndefinedBehaviorSanitizer)
#   - libclang_rt.lsan-x86_64.a   (LeakSanitizer)
# Without compiler-rt, clang -fsanitize=address fails at link time with:
#   cannot find /usr/lib/llvm-18/lib/clang/18/lib/linux/libclang_rt.asan-x86_64.a
# ---------------------------------------------------------------------------
RUN dnf install -y \
        llvm-toolset \
        compiler-rt \
    && dnf clean all

# GCC: the plain gcc package on Rocky 9 is GCC 11 (system default).
# gcc-toolset-13 provides GCC 13 via Software Collections, accessible by
# sourcing /opt/rh/gcc-toolset-13/enable or adding it to PATH.
RUN dnf install -y \
        gcc \
        gcc-c++ \
        gcc-toolset-13 \
        gcc-toolset-13-gcc \
        gcc-toolset-13-gcc-c++ \
    && dnf clean all

# Analysis, debugging, and fuzzing tools from EPEL.
RUN dnf install -y \
        cppcheck \
        valgrind \
        afl++ \
        bear \
        strace \
        ltrace \
        # C standard library + math headers
        # glibc-devel is the Rocky/RHEL equivalent of Debian's libc6-dev
        # It includes math.h, string.h, stdio.h etc.
        glibc-devel \
        gdb \
        binutils \
        file \
        clang-tools-extra \
    && dnf clean all

# Make GCC 13 the default gcc/g++ by prepending the SCL bin directory.
# Using ENV (not `source`) ensures every subsequent RUN inherits it.
ENV PATH="/opt/rh/gcc-toolset-13/root/usr/bin:${PATH}"

RUN gcc --version | head -1 && \
    clang --version | head -1 && \
    echo "Toolchain ready."

# =============================================================================
# Stage 3: sanitizers — compile-time verification that all runtimes link
# =============================================================================
FROM toolchain AS sanitizers

# Compile and run a minimal program with each sanitizer to prove that
# compiler-rt is correctly installed. This stage fails at build time
# (not runtime) if any sanitizer library is missing.
RUN printf '#include <stdio.h>\nint main(void){puts("ok");return 0;}\n' \
        > /tmp/sancheck.c && \
    \
    echo "--- Verifying ASan + UBSan ---" && \
    clang -fsanitize=address,undefined \
          -fno-omit-frame-pointer \
          -g -O1 \
          /tmp/sancheck.c -o /tmp/sancheck_asan && \
    ASAN_OPTIONS=halt_on_error=1 /tmp/sancheck_asan && \
    echo "ASan+UBSan: OK" && \
    \
    echo "--- Verifying TSan ---" && \
    clang -fsanitize=thread \
          -fno-omit-frame-pointer \
          -g -O1 \
          /tmp/sancheck.c -o /tmp/sancheck_tsan && \
    TSAN_OPTIONS=halt_on_error=1 /tmp/sancheck_tsan && \
    echo "TSan: OK" && \
    \
    echo "--- Verifying LSan ---" && \
    clang -fsanitize=leak \
          -fno-omit-frame-pointer \
          -g -O1 \
          /tmp/sancheck.c -o /tmp/sancheck_lsan && \
    LSAN_OPTIONS=verbosity=0 /tmp/sancheck_lsan && \
    echo "LSan: OK" && \
    \
    rm -f /tmp/sancheck.c \
          /tmp/sancheck_asan \
          /tmp/sancheck_tsan \
          /tmp/sancheck_lsan && \
    echo "All sanitizer checks passed."

# =============================================================================
# Stage 4: dev — full interactive development image
# =============================================================================
FROM sanitizers AS dev

RUN dnf install -y \
        bash-completion \
        less \
        vim \
        nano \
        man-db \
        hexedit \
        nmap-ncat \
        iproute \
        doxygen \
        graphviz \
        jq \
    && dnf clean all

# ---------------------------------------------------------------------------
# Install hyperfine via cargo-binstall.
#
# Why NOT wget from GitHub releases?
# The previous approach constructed a URL like:
#   .../hyperfine-v1.18.0-aarch64-unknown-linux-musl.tar.gz
# and fetched it with wget. This consistently fails with exit code 8
# (HTTP server error) inside QEMU-emulated arm64 Docker builds because
# GitHub's CDN returns 403/503 to QEMU network stacks.
#
# cargo-binstall solves this by:
#   1. Reading the crates.io package metadata for the target arch
#   2. Downloading from the correct URL with retry logic built in
#   3. Verifying checksums automatically
# ---------------------------------------------------------------------------
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
    cargo-binstall --no-confirm --no-symlinks hyperfine && \
    hyperfine --version

# Non-root user for interactive development.
RUN useradd -m -s /bin/bash -u 1000 dev
USER dev
WORKDIR /home/dev/workspace

ENV PATH="/opt/rh/gcc-toolset-13/root/usr/bin:/usr/local/bin:${PATH}"

RUN gcc --version | head -1 && \
    clang --version | head -1 && \
    make --version | head -1 && \
    cmake --version | head -1 && \
    cppcheck --version && \
    valgrind --version && \
    gdb --version | head -1 && \
    hyperfine --version && \
    echo "c-env dev image ready."

CMD ["bash"]

# =============================================================================
# Stage 5: ci — non-interactive image for GitHub Actions
# =============================================================================
FROM sanitizers AS ci

WORKDIR /workspace

RUN gcc --version | head -1 && \
    clang --version | head -1 && \
    make --version | head -1 && \
    cppcheck --version && \
    valgrind --version && \
    echo "c-env CI image ready."

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

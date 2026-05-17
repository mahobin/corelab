# =============================================================================
# docker/python/Dockerfile — Python Development Environment
#
# Base: rockylinux/rockylinux:9.7  (system layer)
#       python:3.12-slim            (Python layer — uses Debian slim for pip)
#
# NOTE ON BASE IMAGE CHOICE:
#   The Python stage uses python:${PYTHON_VERSION}-slim (Debian-based) rather
#   than Rocky Linux directly. This is intentional:
#     - python:*-slim ships a pre-built CPython with all stdlib extensions
#     - Building Python from source on Rocky would add 30+ minutes to the build
#     - The fuzz stage (which needs clang) uses Rocky Linux for consistency
#   If a pure Rocky Python image is needed, use python:3.12-slim and accept
#   the Debian lineage, or use the dnf-based fuzz stage pattern below.
#
# Stages:
#   base        → python:3.12-slim + system build deps
#   deps        → pip-installed tooling (linters, type checkers, test runners)
#   bytecode    → Pre-compiled .pyc files for fast container startup
#   dev         → Full interactive image (default target)
#   ci          → Minimal non-interactive image for GitHub Actions
#   fuzz        → Rocky Linux 9.7 + Python + Clang + Atheris
#
# Key fixes vs previous version:
#   1. atheris.__version__ → does not exist; Atheris has no __version__ attr
#      Fix: use importlib.metadata.version("atheris") for the version check,
#      or simply verify the import succeeds (import atheris; print("OK"))
#   2. libfuzzer-dev → doesn't exist as a standalone package anywhere;
#      libFuzzer is bundled inside clang/compiler-rt
#   3. hyperfine installed via cargo-binstall (not fragile wget URLs)
#
# Usage:
#   docker build --target dev                          -t python-env:dev .
#   docker build --target ci                           -t python-env:ci  .
#   docker build --target fuzz                         -t python-env:fuzz .
#   docker build --build-arg PYTHON_VERSION=3.11 --target dev -t python-env:3.11 .
#   docker buildx build --platform linux/amd64,linux/arm64 --target ci .
# =============================================================================

ARG PYTHON_VERSION=3.12

# =============================================================================
# Stage 1: base — Python slim + system build dependencies
# =============================================================================
FROM python:${PYTHON_VERSION}-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    # Unbuffered stdout/stderr — essential for readable CI logs.
    PYTHONUNBUFFERED=1 \
    # Allow .pyc generation (needed by the bytecode stage).
    PYTHONDONTWRITEBYTECODE=0 \
    # Don't look for site-packages in the user home directory.
    PYTHONNOUSERSITE=1 \
    # pip behaviour in CI / root contexts.
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        libffi-dev \
        libssl-dev \
        libsqlite3-dev \
        ca-certificates \
        curl \
        wget \
        git \
        make \
        procps \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel

# =============================================================================
# Stage 2: deps — core Python tooling (granular layers for fast cache hits)
# =============================================================================
FROM base AS deps

# Each group is a separate RUN so a change to one group (e.g. upgrading ruff)
# doesn't invalidate the cache for unrelated groups.

# A — Linting and formatting
RUN pip install ruff black isort

# B — Type checking
RUN pip install mypy types-requests types-PyYAML

# C — Testing and coverage
RUN pip install pytest pytest-cov pytest-xdist pytest-timeout pytest-randomly

# D — Benchmarking
RUN pip install pyperf

# E — Utilities
RUN pip install ipython rich httpx

# =============================================================================
# Stage 3: bytecode — pre-compile installed packages to .pyc
# =============================================================================
FROM deps AS bytecode

# Pre-compiling to .pyc files measurably speeds up container cold starts.
# -q: suppress per-file output.  -j 0: use all available CPUs.
# 2>/dev/null: some stdlib paths produce harmless "syntax error" warnings
# on files that are intentionally not valid Python (e.g. test fixtures).
RUN python -m compileall -q -j 0 \
        /usr/local/lib/python*/site-packages/ \
        /usr/local/lib/python*/ \
    2>/dev/null || true

# =============================================================================
# Stage 4: dev — full interactive development image
# =============================================================================
FROM bytecode AS dev

RUN pip install \
        astpretty \
        astunparse \
        bytecode \
        line_profiler \
        memory_profiler \
        py-spy \
        mkdocs \
        mkdocs-material \
        jupyterlab

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        less \
        vim \
        man-db \
        gdb \
        strace \
        ltrace \
        file \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Install hyperfine via cargo-binstall (arch-aware, no URL construction).
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

RUN useradd -m -s /bin/bash -u 1000 dev
USER dev
WORKDIR /home/dev/workspace

RUN python3 --version && \
    pip --version && \
    ruff --version && \
    black --version && \
    mypy --version && \
    pytest --version && \
    hyperfine --version && \
    echo "python-env dev image ready."

CMD ["bash"]

# =============================================================================
# Stage 5: ci — minimal non-interactive image for GitHub Actions
# =============================================================================
FROM bytecode AS ci

WORKDIR /workspace

RUN python3 --version && \
    pip --version && \
    ruff --version && \
    black --version && \
    mypy --version && \
    pytest --version && \
    python3 -m compileall --help > /dev/null && \
    echo "python-env CI image ready."

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

# =============================================================================
# Stage 6: fuzz — Rocky Linux 9.7 + Python 3.12 + Clang + Atheris
# =============================================================================
FROM rockylinux/rockylinux:9.7 AS fuzz

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore

# Enable EPEL + CRB; install clang (includes compiler-rt with libFuzzer).
# IMPORTANT: There is NO standalone libfuzzer-dev or libfuzzer package on
# any Linux distribution. libFuzzer is compiled into clang/compiler-rt and
# is activated at compile time via -fsanitize=fuzzer — no separate install.
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
        llvm-toolset \
        compiler-rt \
        python3 \
        python3-pip \
        python3-devel \
        gcc \
        gcc-c++ \
        make \
        git \
        ca-certificates \
    && dnf clean all

RUN pip3 install --upgrade pip setuptools wheel

# Atheris uses Clang + libFuzzer (via -fsanitize=fuzzer) which is part of
# compiler-rt. No separate package needed; installing clang + compiler-rt
# gives Atheris everything it needs to compile its C extension.
RUN pip3 install atheris ruff pytest

WORKDIR /workspace

# ---------------------------------------------------------------------------
# Validate Atheris import.
#
# FIX: atheris has NO __version__ attribute (never has). Using
#   atheris.__version__  → AttributeError: module 'atheris' has no attribute '__version__'
#   atheris.version      → same AttributeError
#
# Correct approaches:
#   1. importlib.metadata.version("atheris")  — reads the installed package metadata
#   2. Just verify the import itself succeeds  — sufficient for a build check
#
# We use approach 1 (importlib.metadata) as it also validates the package is
# properly registered in the Python environment (pip install succeeded fully).
# ---------------------------------------------------------------------------
RUN python3 -c "
import atheris
import importlib.metadata
ver = importlib.metadata.version('atheris')
print(f'Atheris {ver} import OK')
"

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

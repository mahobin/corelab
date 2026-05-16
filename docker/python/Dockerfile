# =============================================================================
# docker/python/Dockerfile — Python Development Environment
#
# Stages:
#   base        → Python 3.12 slim + system build deps
#   deps        → pip-installed core packages (linters, test tools, type check)
#   bytecode    → Pre-compiles stdlib and installed packages (faster cold start)
#   dev         → Full interactive image with extra dev conveniences (default)
#   ci          → Minimal non-interactive image for GitHub Actions
#   fuzz        → Adds Atheris + Clang for coverage-guided fuzzing
#
# Design choices:
#   - Multi-version support: ARG PYTHON_VERSION lets you build 3.11/3.12/3.13
#     with a single Dockerfile.
#   - pip layer is separated from system layer so `pip install` changes
#     don't invalidate apt cache.
#   - All pip installs use --no-cache-dir to keep image layers small.
#   - Non-root user in dev stage for security.
#
# Usage:
#   docker build --target dev                          -t python-env:dev .
#   docker build --target ci                           -t python-env:ci  .
#   docker build --target fuzz                         -t python-env:fuzz .
#   docker build --target dev --build-arg PYTHON_VERSION=3.11 -t python-env:3.11 .
#   docker buildx build --platform linux/amd64,linux/arm64 --target ci .
# =============================================================================

ARG PYTHON_VERSION=3.12

# =============================================================================
# Stage 1: base — Python slim with system dependencies
# =============================================================================
FROM python:${PYTHON_VERSION}-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    # Unbuffered stdout/stderr — essential for readable CI logs.
    PYTHONUNBUFFERED=1 \
    # Prevent .pyc files being written to disk in the container.
    PYTHONDONTWRITEBYTECODE=0 \
    # Don't look for site-packages in the user directory.
    PYTHONNOUSERSITE=1 \
    # pip: don't warn about running as root in CI.
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        # Build deps for compiled extensions (e.g. numpy, lxml, cryptography)
        build-essential \
        gcc \
        g++ \
        # Foreign function libraries
        libffi-dev \
        libssl-dev \
        # SQLite (used by stdlib sqlite3 module)
        libsqlite3-dev \
        # General utilities
        ca-certificates \
        curl \
        wget \
        git \
        make \
        # For subprocess-heavy tests
        procps \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel to latest before any installs.
RUN pip install --upgrade pip setuptools wheel

# =============================================================================
# Stage 2: deps — core Python tooling layer
# =============================================================================
FROM base AS deps

# Install in groups so Docker cache is granular:
#   Group A: linting + formatting
#   Group B: type checking
#   Group C: testing + coverage
#   Group D: benchmarking
#   Group E: dev utilities

# A — Linting and formatting
RUN pip install \
        ruff \
        black \
        isort

# B — Type checking
RUN pip install \
        mypy \
        types-requests \
        types-PyYAML

# C — Testing
RUN pip install \
        pytest \
        pytest-cov \
        pytest-xdist \
        pytest-timeout \
        pytest-randomly

# D — Benchmarking
RUN pip install \
        pyperf

# E — Utilities
RUN pip install \
        ipython \
        rich \
        httpx

# =============================================================================
# Stage 3: bytecode — pre-compile all installed packages
# =============================================================================
FROM deps AS bytecode

# Pre-compiling to .pyc speeds up container startup significantly.
# -q suppresses per-file output; -j 0 uses all available CPUs.
RUN python -m compileall -q -j 0 \
        /usr/local/lib/python*/site-packages/ \
        /usr/local/lib/python*/ \
    2>/dev/null || true

# =============================================================================
# Stage 4: dev — full interactive development image
# =============================================================================
FROM bytecode AS dev

# Additional developer-only packages.
RUN pip install \
        # AST inspection
        astpretty \
        astunparse \
        # Bytecode inspection
        # (dis is stdlib; bytecode library adds programmatic access)
        bytecode \
        # Profiling
        line_profiler \
        memory_profiler \
        py-spy \
        # Documentation
        mkdocs \
        mkdocs-material \
        # Notebook support
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
        # For CPython extension development
        python3-dbg \
    && rm -rf /var/lib/apt/lists/*

# Install hyperfine.
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
RUN useradd -m -s /bin/bash -u 1000 dev
USER dev
WORKDIR /home/dev/workspace

# Validate.
RUN python3 --version && \
    pip --version && \
    python3 -c "import sys; print('Python', sys.version)" && \
    ruff --version && \
    black --version && \
    mypy --version && \
    pytest --version && \
    hyperfine --version

CMD ["bash"]

# =============================================================================
# Stage 5: ci — minimal non-interactive image for GitHub Actions
# =============================================================================
FROM bytecode AS ci

WORKDIR /workspace

# Validate CI toolset.
RUN python3 --version && \
    pip --version && \
    ruff --version && \
    black --version && \
    mypy --version && \
    pytest --version && \
    python3 -m compileall --help > /dev/null

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

# =============================================================================
# Stage 6: fuzz — Atheris coverage-guided fuzzing image
# =============================================================================
FROM base AS fuzz

# Atheris requires Clang and LLVM at install time so it can link against
# libFuzzer. There is NO separate libfuzzer-dev package on Debian/Ubuntu —
# libFuzzer is part of the Clang/LLVM installation itself and is accessed
# via `-fsanitize=fuzzer`. Installing clang + llvm is sufficient.
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        clang \
        llvm \
    && rm -rf /var/lib/apt/lists/*

# Install Atheris and its Python-level dependencies.
# Atheris must be installed after Clang is available so it can link libFuzzer.
RUN pip install \
        atheris \
        ruff \
        pytest

WORKDIR /workspace

RUN python3 -c "import atheris; print('Atheris', atheris.__version__)"

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]

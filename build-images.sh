#!/usr/bin/env bash
help=$(
  cat <<'HEREDOC'
-----------------------------------------------------------------------------
  This script updates the Docker images.
-----------------------------------------------------------------------------
 - Options:
   --help  : Shows this help.
   --push  : Push the images to Docker Hub after build. Make sure you have
             logged in.
   --buildx: Multi-architecture build. Currently for AMD64, ARM64, ARMv6 and v7.
HEREDOC
)

# Show help
echo "$@" | grep '\-h' >/dev/null && {
  echo "$help"
  exit 0
}

set -eu

# -----------------------------------------------------------------------------
#  Constants
# -----------------------------------------------------------------------------
NAME_IMAGE="keinos/sqlite3"
NAME_FILE_VERSION="VERSION_SQLite3.txt"
NAME_MULTIARCH_BUILDER="multi-arch-build"
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'

# Include previous version of SQLite3 (VERSION_SQLITE3)
# shellcheck source=./VERSION_SQLite3.txt
source "$NAME_FILE_VERSION"

# Get current short version of SQLite3
VERSION_SQLITE3_SHORT=$(echo "$VERSION_SQLITE3" | awk '{print $1}')
NAME_IMAGE_LATEST="${NAME_IMAGE}:latest"
NAME_IMAGE_VERSIONED="${NAME_IMAGE}:${VERSION_SQLITE3_SHORT}"

# -----------------------------------------------------------------------------
#  Functions
# -----------------------------------------------------------------------------
# Colored echo function
echoGreen() {
  echo -e "${COLOR_GREEN}${*}${COLOR_NONE}"
}
echoRed() {
  echo -e "${COLOR_RED}${*}${COLOR_NONE}"
}

# Check supported platform and architectures.
# The first argument is the target to check.
#   ex: checkArchitecture "linux/amd64"
isPlatformSupported() {
  docker buildx ls | grep default | grep "$1" >/dev/null
  return $?
}

# Returns true if buildx is supported.
isAvailableBuildx() {
  docker buildx version 1>/dev/null 2>/dev/null || {
    echoRed '- Docker buildx is not installed or enabled.'
    return 1
  }

  return 0
}

# Returns true if all platform architectures are supported.
isReadyToBuild() {
  isPlatformSupported "linux/amd64" || {
    echoRed '- Docker buildx is not configured for AMD64.'
    return 1
  }

  isPlatformSupported "linux/arm64" || {
    echoRed '- Docker buildx is not configured for ARM64.'
    return 1
  }

  isPlatformSupported "linux/arm/v7" || {
    echoRed '- Docker buildx is not configured for ARMv7.'
    return 1
  }

  isPlatformSupported "linux/arm/v6" || {
    echoRed '- Docker buildx is not configured for ARMv6.'
    return 1
  }

  return 0
}

# =============================================================================
#  Main
# =============================================================================
echoGreen "- Building image with SQLite3 version: ${VERSION_SQLITE3_SHORT}"
echo "  ${VERSION_SQLITE3}"

# -----------------------------------------------------------------------------
#  Build
# -----------------------------------------------------------------------------
# Build regular image.
# If no "--buildx" option is given, then only for the current platform is built.
echo "$@" | grep 'buildx' >/dev/null || {
  echoGreen "- Building latest image (${NAME_IMAGE_LATEST}) ..."
  docker build --tag "$NAME_IMAGE_LATEST" .

  echoGreen "- Building versioned tagged image ($NAME_IMAGE_VERSIONED) ..."
  docker build --tag "$NAME_IMAGE_VERSIONED" .
}

# Build multi-architecture image if "--buildx" option is set
echo "$@" | grep 'buildx' >/dev/null && {
  echoGreen "- Multi-arch option detected ... "

  echoGreen "  Checking login status ..."
  docker login 1>/dev/null 2>/dev/null || {
    echoRed "  Please login to Docker Hub first."
    exit 1
  }
  echo "  Logged in"

  doPush=""
  echo "$@" | grep 'push' >/dev/null && {
    echoGreen "- Push option detected ... "
    echo      "  The built images will be pushed to Docker Hub as well."
    doPush="--push"
  }

  # Check available platforms required
  isReadyToBuild || {
    echoRed '- Docker buildx is not configured for required platforms.'
    exit 1
  }

  echoGreen "- Building multi-architecture image ... (This may take a while) ..."

  # Create builder
  docker buildx ls | grep "$NAME_MULTIARCH_BUILDER" >/dev/null || {
    echo "  Creating builder ..."
    docker buildx create --use --name "$NAME_MULTIARCH_BUILDER"
  }

  # Boot the builder
  echo "  Bootstrapping builder ..."
  docker buildx inspect --builder "$NAME_MULTIARCH_BUILDER" --bootstrap

  # Build latest image (multi-arch)
  docker buildx build \
    $doPush \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "$NAME_IMAGE_LATEST" .

  # Build versioned image (multi-arch)
  docker buildx build \
    $doPush \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "$NAME_IMAGE_VERSIONED" .

  docker buildx stop "$NAME_MULTIARCH_BUILDER"
}

echoGreen "- Done."

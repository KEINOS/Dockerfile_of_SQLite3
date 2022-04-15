#!/usr/bin/env bash
help=$(
  cat <<'HEREDOC'
-----------------------------------------------------------------------------
  This script updates the VERSION_SQLite3.txt and the Docker image.
-----------------------------------------------------------------------------
 - Options:
   --help  : Shows this help.
   --force : Force the update process even if the version is the same.
   --commit: Git commit the version changes.
   --push  : Push the image to Docker Hub. If `--commit` is set it will push
             the git commit to GitHub as well.
   --buildx: Multi-architecture build. Currently for AMD64 and ARM64.

 - Note:
   - By default, if there are no updates, the script exits with status 0.
   - This script **REMOVES** ("prunes") unused containers, images and builders.
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
NAME_FILE_VERSION="VERSION_SQLite3.txt"
NAME_JSON_VERSION="SQLite3-shields.io-badge.json"
NAME_MULTIARCH_BUILDER="multi-arch-build"
NAME_TAG_IMAGE_TEST="test-$(base64 </dev/urandom | tr -cd 'a-z0-9' | head -c 10)"
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_NONE='\033[0m'

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

# Define cleanup function.
# It removes ("prunes") unused containers, images and builders.
cleanup() {
  echoGreen "- Cleaning up ..."

  echoGreen "  - Removing test image ..."
  docker image rm "$NAME_TAG_IMAGE_TEST" --force

  echoGreen "  - Removing prune containers ..."
  docker container prune --force

  echoGreen "  - Removing prune images ..."
  docker image prune --force

  isAvailableBuildx && {
    echoGreen "  - Removing prune builders ..."
    docker buildx prune --all --force
  }
}
# Ensure cleanup function is called on exit
trap cleanup EXIT

# =============================================================================
#  Main
# =============================================================================
echoGreen "- Name of test image: ${NAME_TAG_IMAGE_TEST}"

# Include previous version of SQLite3
# shellcheck source=./VERSION_SQLite3.txt
source "$NAME_FILE_VERSION"

# Build and run container to get the version
echoGreen "- Building latest image to compare ..."
docker build --tag "$NAME_TAG_IMAGE_TEST" .
VERSION_SQLITE3_LATEST=$(docker run --rm "$NAME_TAG_IMAGE_TEST" sqlite3 --version)

echoGreen "- Previous SQLite3 version was: ${VERSION_SQLITE3}"
echoGreen "- Current  SQLite3 version is : ${VERSION_SQLITE3_LATEST}"

# -----------------------------------------------------------------------------
#  Version check and update version file
# -----------------------------------------------------------------------------
# Compare version
if [ "${VERSION_SQLITE3}" = "${VERSION_SQLITE3_LATEST}" ]; then
  echoGreen '- No update found.'
  # If not forced then show message and exit
  echo "$@" | grep 'force' >/dev/null || {
    echo '  To force create image use "--force" option.'
    exit 0
  }
fi

echo "$@" | grep 'force' >/dev/null || {
  echoGreen "- Update found. Udating: ${NAME_FILE_VERSION} ..."
}
echo "$@" | grep 'force' >/dev/null && {
  echoRed "- Force option detected. Forcing update the image ..."
}

# Get current short version of SQLite3
VERSION_SQLITE3_SHORT=$(echo "$VERSION_SQLITE3_LATEST" | awk '{print $1}')

# Update version (overwrites the version file)
echo "VERSION_SQLITE3='${VERSION_SQLITE3_LATEST}'" >"$NAME_FILE_VERSION" || {
  echoRed '- Fail to update NAME_FILE_VERSION.'
  exit 1
}

cat <<HEREDOC >"$NAME_JSON_VERSION"
{
  "schemaVersion": 1,
  "label": "SQLite",
  "message": "${VERSION_SQLITE3_SHORT}",
  "color": "blue",
  "namedLogo": "sqlite"
}
HEREDOC

# Create image tag for latest and versioning
echoGreen "- Creating tagged images ... "
NAME_TAG_IMAGE_LATEST="keinos/sqlite3:latest"
NAME_TAG_IMAGE_VERSIONED="keinos/sqlite3:${VERSION_SQLITE3_SHORT}"

# -----------------------------------------------------------------------------
#  Build
# -----------------------------------------------------------------------------
# Build regular image.
# If no "--buildx" option is given, then only for the current platform is built.
echo "$@" | grep 'buildx' >/dev/null || {
  docker build --tag "$NAME_TAG_IMAGE_LATEST" .
  docker build --tag "$NAME_TAG_IMAGE_VERSIONED" .
}

# Build multi-architecture image if "--buildx" option is set
echo "$@" | grep 'buildx' >/dev/null && {
  echoGreen "- Multi-arch option detected ... "

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
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "$NAME_TAG_IMAGE_LATEST" .

  # Build versioned image (multi-arch)
  docker buildx build \
    --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
    --tag "$NAME_TAG_IMAGE_VERSIONED" .
}

# -----------------------------------------------------------------------------
#  Push built Docker images
# -----------------------------------------------------------------------------
echo "$@" | grep 'push' >/dev/null && {
  echoGreen "- Pushing tagged images ... "

  echo "  Pushing versioned image: ${NAME_TAG_IMAGE_VERSIONED}"
  docker push "$NAME_TAG_IMAGE_VERSIONED"

  echo "  Pushing latest image: ${NAME_TAG_IMAGE_LATEST}"
  docker push "$NAME_TAG_IMAGE_LATEST"
}

# -----------------------------------------------------------------------------
#  Commit and/or push git changes
# -----------------------------------------------------------------------------
echo "$@" | grep 'commit' >/dev/null && {
  echoGreen "- Git committing changes ... "
  git add .
  git commit -m "Update SQLite3 to ${VERSION_SQLITE3_SHORT}"

  echo "$@" | grep 'push' && {
    echoGreen "- Pushing committed git changes ... "
    git push
  }

  exit $?
}

echoGreen "- Done."
echo
echo "Please commit and push the changes."
echo

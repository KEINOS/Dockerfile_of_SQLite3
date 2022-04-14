#!/usr/bin/env bash
help=$(
  cat <<'HEREDOC'
-----------------------------------------------------------------------------
  This script updates the VERSION_SQLite3.txt and the Docker image.
-----------------------------------------------------------------------------
 - Options:
   --force : Force the update process even if the version is the same.
   --commit: Git commit the version changes.
   --push  : Push the image to Docker Hub. If `--commit` is set it will push
             the git commit to GitHub as well.

 - Notes:
   - If there is no update, it exits with status 0.
   - This script will `prune` the unused contaier and images.
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

# Define cleanup function
cleanup() {
  echoGreen "- Cleaning up ..."
  echoGreen "  - Removing test image ..."
  docker image rm "$NAME_TAG_IMAGE_TEST" -f
  echoGreen "  - Removing prune containers ..."
  docker container prune -f
  echoGreen "  - Removing prune images ..."
  docker image prune -f
}

# Ensure cleanup function is called on exit
trap cleanup EXIT

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------
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

# Create latest and versioned tagged images
echoGreen "- Creating tagged images ... "
NAME_TAG_IMAGE_LATEST="keinos/sqlite3:latest"
NAME_TAG_IMAGE_VERSIONED="keinos/sqlite3:${VERSION_SQLITE3_SHORT}"
docker build --tag "$NAME_TAG_IMAGE_LATEST" .
docker build --tag "$NAME_TAG_IMAGE_VERSIONED" .

# Push built Docker images
echo "$@" | grep 'push' >/dev/null && {
  echoGreen "- Pushing tagged images ... "

  echo "  Pushing versioned image: ${NAME_TAG_IMAGE_VERSIONED}"
  docker push "$NAME_TAG_IMAGE_VERSIONED"

  echo "  Pushing latest image: ${NAME_TAG_IMAGE_LATEST}"
  docker push "$NAME_TAG_IMAGE_LATEST"
}

# Commit git changes
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

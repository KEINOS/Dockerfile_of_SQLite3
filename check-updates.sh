#!/usr/bin/env bash

help=$(
  cat <<'HEREDOC'
-----------------------------------------------------------------------------
  This script updates the VERSION_SQLite3.txt and the Docker image.
-----------------------------------------------------------------------------
 - Options:
   --help  : Shows this help.
   --force : Force the update process even if the version is the same.
 - Notes:
   - By default, if there are no updates, the script exits with status 0.
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

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------
echoGreen "- Name of test image: ${NAME_TAG_IMAGE_TEST}"

# Include previous version of SQLite3
# shellcheck source=./VERSION_SQLite3.txt
source "$NAME_FILE_VERSION"

# Build and run container to get the version
echoGreen "- Building latest image to compare ..."
docker build --tag "$NAME_TAG_IMAGE_TEST" . || {
  echo 'Fail to build the image.'
  exit 1
}

VERSION_SQLITE3_LATEST=$(docker run --rm "$NAME_TAG_IMAGE_TEST" sqlite3 --version)
VERSION_OS_LATEST=$(docker run --rm "$NAME_TAG_IMAGE_TEST" cat /etc/alpine-release)

echoGreen "- Previous SQLite3 version was: ${VERSION_SQLITE3}"
echoGreen "- Current  SQLite3 version is : ${VERSION_SQLITE3_LATEST}"

# Compare version
if [ "${VERSION_SQLITE3}" = "${VERSION_SQLITE3_LATEST}" ]; then
  if [ "${VERSION_OS:-unknown}" = "${VERSION_OS_LATEST}" ]; then
    echoGreen '- No update found.'
    # If not forced then show message and exit
    echo "$@" | grep 'force' >/dev/null || {
      echo '  To force create image use "--force" option.'
      exit 0
    }
  fi
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

# Append the OS version
echo "VERSION_OS='${VERSION_OS_LATEST}'" >>"$NAME_FILE_VERSION" || {
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

echoGreen "- Done."
git status | grep modified >/dev/null && {
  echoGreen "- There are some changes. Please commit and push the changes."
}

echo

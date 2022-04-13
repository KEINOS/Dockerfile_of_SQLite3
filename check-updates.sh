#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  This script updates the VERSION_SQLite3.txt. It checks if there's an update
#  in SQLite3 then commit/push the changes.
#  If there is no update, it exits with status 1; if there is an update, it
#  performs the update and returns the resulting status code.
#
#  - Notes:
#    - This script must be run in the local.
#    - This script will `prune` the contaier and images.
# -----------------------------------------------------------------------------

set -eu

# Create random image name for testing
NAME_TAG_IMAGE="test-$(base64 </dev/urandom | tr -cd 'a-z0-9' | head -c 10)"
echo "- Name of test image: ${NAME_TAG_IMAGE}"

# Include previous version of SQLite3
source ./VERSION_SQLite3.txt
echo "- Previous version was: ${VERSION_SQLITE3}"

# Build and run container to get the version
docker build --tag "$NAME_TAG_IMAGE" . &&
  VERSION_SQLITE3_LATEST=$(docker run --rm "$NAME_TAG_IMAGE" sqlite3 --version) &&
  docker container prune -f &&
  docker image rm "$NAME_TAG_IMAGE" -f &&
  docker image prune -f
if test $? -ne 0; then
  echo '- Fail to build or run container.'
  exit 1
fi
echo "- Current version is: ${VERSION_SQLITE3_LATEST}"

# Compare version
if [ "${VERSION_SQLITE3}" = "${VERSION_SQLITE3_LATEST}" ]; then
  echo '- No update found.'
  exit 1
fi

# Shor version for commit message
VERSION_SQLITE3_SHORT=$(echo "$VERSION_SQLITE3_LATEST" | awk '{print $1}')

# Git commit/push to origin
echo '- Update found. Udating ... '
echo "VERSION_SQLITE3='${VERSION_SQLITE3_LATEST}'" >VERSION_SQLite3.txt
git add . &&
  git commit -m "feat: v${VERSION_SQLITE3_SHORT}" &&
  git push origin

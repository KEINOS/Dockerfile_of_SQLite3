# syntax=docker/dockerfile:1
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true

# -----------------------------------------------------------------------------
#  Build Stage
#
#  We split the RUN layers to cache them separately to fasten the rebuild process
#  in case of build fails during multi-stage builds.
# -----------------------------------------------------------------------------
FROM alpine:latest AS build

# Install dependencies
RUN \
  apk update && \
  apk upgrade && \
  apk add \
  alpine-sdk \
  build-base  \
  tcl-dev \
  tk-dev \
  mesa-dev \
  jpeg-dev \
  libjpeg-turbo-dev

# Download latest release
RUN \
  wget \
  -O sqlite.tar.gz \
  https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release && \
  tar xvfz sqlite.tar.gz

# Configure and make SQLite3 binary
RUN \
  ./sqlite/configure --prefix=/usr && \
  make && \
  make install && \
  # Smoke test
  sqlite3 --version

# Copy the test script and run it
COPY run-test.sh /run-test.sh

RUN /run-test.sh

# -----------------------------------------------------------------------------
#  Main Stage
# -----------------------------------------------------------------------------
FROM alpine:latest

ARG BUILDKIT_SBOM_SCAN_STAGE=true

COPY --from=build /usr/bin/sqlite3 /usr/bin/sqlite3
COPY run-test.sh /run-test.sh

# Ensure to be up-to-date (fix issue #32, CVE-2022-3996)
RUN apk update --no-cache && \
  apk upgrade --no-cache && \
  # Install tini to ensure that the default signal handlers work 
  # (e.g., SIGTERM, SIGINT are handled correctly, not just SIGKILL)
  apk add --no-cache tini

# Create a user and group for SQLite3 to avoid: Dockle CIS-DI-0001
ENV \
  USER_SQLITE=sqlite \
  GROUP_SQLITE=sqlite
RUN \
  addgroup -S $GROUP_SQLITE && \
  adduser  -S $USER_SQLITE -G $GROUP_SQLITE

# Set user
USER $USER_SQLITE

# Run simple test
RUN /run-test.sh

# Set container's default entrypoint as `tini`
ENTRYPOINT ["/sbin/tini", "-g", "--"]

# Set container's default command as `sqlite3`
CMD ["/usr/bin/sqlite3"]

# Avoid: Dockle CIS-DI-0006
HEALTHCHECK \
  --start-period=1m \
  --interval=5m \
  --timeout=3s \
  CMD /usr/bin/sqlite3 --version || exit 1

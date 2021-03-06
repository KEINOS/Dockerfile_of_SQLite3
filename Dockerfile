FROM keinos/alpine:latest AS build-env

COPY run-test.sh /run-test.sh

RUN \
  apk add --update \
    alpine-sdk \
    build-base  \
    tcl-dev \
    tk-dev \
    mesa-dev \
    jpeg-dev \
    libjpeg-turbo-dev \
  # Download latest release
  && wget \
    -O sqlite.tar.gz \
    https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release \
  && tar xvfz sqlite.tar.gz \
  # Configure and make SQLite3 binary
  && ./sqlite/configure --prefix=/usr \
  && make \
  && make install \
  # Smoke test
  && sqlite3 --version \
  && /run-test.sh

# -----------------------------------------------------------------------------
FROM keinos/alpine:latest

COPY --from=build-env /usr/bin/sqlite3 /usr/bin/sqlite3
COPY run-test.sh /run-test.sh

# Create a group and user for SQLite3 to avoid: Dockle CIS-DI-0001
ENV \
  USER_SQLITE=sqlite \
  GROUP_SQLITE=sqlite

RUN addgroup -S $GROUP_SQLITE \
  && adduser  -S $USER_SQLITE -G $GROUP_SQLITE

USER $USER_SQLITE

# Set container's default command as `sqlite3`
CMD /usr/bin/sqlite3

# Avoid: Dockle CIS-DI-0006
HEALTHCHECK \
  --start-period=1m \
  --interval=5m \
  --timeout=3s \
  CMD /usr/bin/sqlite3 --version || exit 1

FROM keinos/alpine:latest AS build-env

COPY run-test.sh /run-test.sh
RUN apk add --update \
      alpine-sdk \
      build-base  \
      tcl-dev \
      tk-dev \
      mesa-dev \
      jpeg-dev \
      libjpeg-turbo-dev \
    && wget \
      -O sqlite.tar.gz \
      https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release \
    && tar xvfz sqlite.tar.gz \
    && ./sqlite/configure --prefix=/usr \
    && make \
    && make install \
    && sqlite3 --version \
    && /run-test.sh

FROM keinos/alpine:latest
COPY --from=build-env /usr/bin/sqlite3 /usr/bin/sqlite3
COPY run-test.sh /run-test.sh
CMD sqlite3

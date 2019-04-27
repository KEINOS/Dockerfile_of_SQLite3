FROM keinos/alpine:latest AS build-env

RUN apk add --update alpine-sdk

ENV NAME_FILE sqlite-autoconf-3280000
RUN wget http://www.sqlite.org/2019/$NAME_FILE.tar.gz && \
    tar xvfz $NAME_FILE.tar.gz && \
    ./$NAME_FILE/configure --prefix=/usr && \
    make && \
    make install && \
    sqlite3 --version

FROM alpine:latest
COPY --from=build-env /usr/bin/sqlite3 /usr/bin/sqlite3
COPY run-test.sh /run-test.sh
CMD sqlite3

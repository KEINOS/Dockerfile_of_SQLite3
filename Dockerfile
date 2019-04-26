FROM alpine AS build-env

ENV NAME_FILE sqlite-autoconf-3170000

RUN apk add --update alpine-sdk && \
    wget http://www.sqlite.org/2017/$NAME_FILE.tar.gz && \
    tar xvfz $NAME_FILE.tar.gz && \
    ./$NAME_FILE/configure --prefix=/usr && \
    make && \
    make install && \
    sqlite3 --version

FROM alpine  
COPY --from=build-env /usr/bin/sqlite3 /usr/bin/sqlite3
COPY run-test.sh /run-test.sh
CMD sqlite3

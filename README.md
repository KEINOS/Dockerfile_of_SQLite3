<!-- markdownlint-disable MD001 MD033 MD034 MD041 -->
# Dockerfile of SQLite3

Alpine Docker image of SQLite3 built from the latest source code.

```bash
docker pull keinos/sqlite3:latest
```

- Current SQLite3 version:
  - [![SQLite Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FKEINOS%2FDockerfile_of_SQLite3%2Fmaster%2FSQLite3-shields.io-badge.json)](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/VERSION_SQLite3.txt)
  - [View Available Tags (SQLite version)](https://hub.docker.com/r/keinos/sqlite3/tags) @ DockerHub
- Supported Architecture:
  - AMD64, ARM64, ARMv6, ARMv7
- Scan Status:
  - [![Snyk Docker Scan](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container-analysis.yml/badge.svg)](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container-analysis.yml)
  - [![Container Scan](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container_scan.yml/badge.svg)](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container_scan.yml)

<details><summary>Image Information (Dockerfile, Security Scan, etc.)</summary>

- Repositories/Registries:
  - [Image Registry](https://hub.docker.com/r/keinos/sqlite3)  @ DockerHub
  - [Dockerfile](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/Dockerfile) @ GitHub
  - [Issues](https://github.com/KEINOS/Dockerfile_of_SQLite3/issues) @ GitHub
- Build Info:
  - Base Image: `alpine:latest`
  - SQLite3 Source: [https://www.sqlite.org/src/](https://www.sqlite.org/src/doc/trunk/README.md) @ SQLite.org
  - Update Interval: [Once a week](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/.github/workflows/weekly-update.yml)
- Basic Vulnerability Scan:
  - [Snyk Docker Scan](https://docs.snyk.io/integrate-with-snyk/snyk-ci-cd-integrations/github-actions-for-snyk-setup-and-checking-for-vulnerabilities/snyk-docker-action) and [Grype Container Scan](https://github.com/anchore/scan-action) on push, PR and merge.
  - Scan Interval: Once a week.
  - See the [Security overview](https://github.com/KEINOS/Dockerfile_of_SQLite3/security) for the details.

</details>

## Usage

### Pull the latest image

```shellsession
$ docker pull keinos/sqlite3:latest
**snip**
```

<details><summary>SBOM Support</summary>

The images supports [SBOM](https://www.cisa.gov/sbom). You can check the software components used in the image as below.

```shellsession
$ docker sbom keinos/sqlite3:latest
Syft v0.43.0
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged packages      [14 packages]

NAME                    VERSION      TYPE
alpine-baselayout       3.6.5-r0     apk
alpine-baselayout-data  3.6.5-r0     apk
alpine-keys             2.4-r1       apk
apk-tools               2.14.4-r0    apk
busybox                 1.36.1-r29   apk
busybox-binsh           1.36.1-r29   apk
ca-certificates-bundle  20240226-r0  apk
libcrypto3              3.3.1-r0     apk
libssl3                 3.3.1-r0     apk
musl                    1.2.5-r0     apk
musl-utils              1.2.5-r0     apk
scanelf                 1.3.7-r2     apk
ssl_client              1.36.1-r29   apk
zlib                    1.3.1-r1     apk
```
</details>

### Specify the version to pull

```shellsession
$ docker pull keinos/sqlite3:3.44.2
...
```

### Build locally

```shellsession
$ docker build -t sqlite3:local https://github.com/KEINOS/Dockerfile_of_SQLite3.git
...
```

### Interactive

Running `sqlite3` command inside the container interactively.

```shellsession
$ docker run --rm -it -v "$(pwd):/workspace" -w /workspace keinos/sqlite3
SQLite version 3.28.0 2019-04-16 19:49:53
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .open ./sample.db
sqlite> CREATE TABLE table_sample(timestamp TEXT, description TEXT);
sqlite> INSERT INTO table_sample VALUES(datetime('now'),'First sample data. Foo');
sqlite> INSERT INTO table_sample VALUES(datetime('now'),'Second sample data. Bar');
sqlite> .quit
$ ls
sample.db
```

- Note that you need to mount the working directory as a volume to the container.

### Command

- Running `sqlite3 --version` command:

```shellsession
$ docker run --rm keinos/sqlite3 sqlite3 --version
3.38.2 2022-03-26 13:51:10 d33c709cc0af66bc5b6dc6216eba9f1f0b40960b9ae83694c986fbf4c1d6f08f
```

- Executing SQL query to the mounted database:

```shellsession
$ ls
sample.db
$ docker run --rm -it -v "$(pwd):/workspace" keinos/sqlite3 sqlite3 /workspace/sample.db -header -column 'SELECT rowid, * FROM table_sample;'
rowid  timestamp            description
-----  -------------------  -----------------------
1      2022-04-16 14:09:52  First sample data. Foo
2      2022-04-16 14:09:58  Second sample data. Bar
```

- Note that you need to mount the working directory as a volume to the container.

### Run test

This container includes a [simple test script](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/run-test.sh).

You can run the script to see if the container and `sqlite3` binary is working. Though, not sutiable for HEALTHCHECK usage.

```shellsession
$ docker run --rm keinos/sqlite3 /run-test.sh
- Creating test DB ... created
rowid  timestamp            description
-----  -------------------  -----------------------
1      2022-04-16 14:18:34  First sample data. Hoo
2      2022-04-16 14:18:34  Second sample data. Bar
- Testing ...
  1st row value ... OK
  2nd row value ... OK

- Test result:
success
$ echo $?
0
```

- [Let us know](https://github.com/KEINOS/Dockerfile_of_SQLite3/issues) if you have any test to be included.

## ToDo

- [x] ~~ARM support for DockerHub~~ (Issue #[2](https://github.com/KEINOS/Dockerfile_of_SQLite3/issues/2), PR #[20](https://github.com/KEINOS/Dockerfile_of_SQLite3/pull/20))

## License

- Dockerfile: [MIT License](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/LICENSE.md) by [The Dockerfile of SQLite3 Contributors](https://github.com/KEINOS/Dockerfile_of_SQLite3/graphs/contributors).
- SQLite: [Public Domain](https://sqlite.org/copyright.html) by [D. Richard Hipp](https://en.wikipedia.org/wiki/D._Richard_Hipp) and [SQLite.org](https://sqlite.org/).
- The below packages in the container are: [GPL-3.0-or-later](https://spdx.org/licenses/GPL-3.0-or-later.html)
  - [GNU patch](https://savannah.gnu.org/projects/patch/)
  - [GNU make](https://www.gnu.org/software/make/)
  - [GNU dbm](https://www.gnu.org.ua/software/gdbm/) (gdbm)
  - [Debian fakeroot](https://salsa.debian.org/clint/fakeroot)
  - [GNU Readline Library](https://tiswww.cwru.edu/php/chet/readline/rltop.html)
  - [GNU Tar](https://www.gnu.org/software/tar/)

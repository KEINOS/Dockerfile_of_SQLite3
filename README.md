<!-- markdownlint-disable MD001 MD033 MD034 MD041 -->
[![SQLite Version](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FKEINOS%2FDockerfile_of_SQLite3%2Fmaster%2FSQLite3-shields.io-badge.json)](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/VERSION_SQLite3.txt)

# Dockerfile of SQLite3

Alpine Docker image of SQLite3 built from the latest source code.

```bash
docker pull keinos/sqlite3:latest
```

- [View Available Tags (SQLite version)](https://hub.docker.com/r/keinos/sqlite3/tags) @ DockerHub
- Current SQLite3 version: [VERSION_SQLite3.txt](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/VERSION_SQLite3.txt)

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
  - [Snyk Docker Scan](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/.github/workflows/snyk_scan.yml) and [Azure Container Scan](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/.github/workflows/azure_scan.yml) on push, PR and merge.
  - Scan Interval: Once a week.
  - See the [Security overview](https://github.com/KEINOS/Dockerfile_of_SQLite3/security) for the details.

</details>

## Usage

### Pull the latest image

Docker will pull the latest image when it's used. Though, you can pull (download) the latest image manually as below:

```shellsession
$ docker pull keinos/sqlite3:latest
...
```

Or, you can build the latest image locally as below:

```shellsession
$ git clone https://github.com/KEINOS/Dockerfile_of_SQLite3.git
$ cd Dockerfile_of_SQLite3
$ docker build -t keinos/sqlite3:latest .
...
```

### Interactive

Running `sqlite3` command inside the container interactively.

```shellsession
$ docker run --rm -it -v "$(pwd)/your.db:/your.db" keinos/sqlite3
SQLite version 3.28.0 2019-04-16 19:49:53
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .open /your.db
sqlite> .quit
```

- Note that you need to mount the DB file as a volume to the container.

### Command

Running `sqlite3 --version` command for example.

```shellsession
$ docker run --rm keinos/sqlite3 sqlite3 --version
3.28.0 2019-04-16 19:49:53 884b4b7e502b4e991677b53971277adfaf0a04a284f8e483e2553d0f83156b50
```

### Run test

This container includes a [simple test script](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/run-test.sh).

You can run the script to see if the container and `sqlite3` binary is working.

```shellsession
$ docker run --rm keinos/sqlite3 /run-test.sh
/usr/bin/sqlite3
2019-04-27 09:05:09|First sample data. Hoo
2019-04-27 09:05:09|Second sample data. Hoo
$ echo $?
0
```

[Let us know](https://github.com/KEINOS/Dockerfile_of_SQLite3/issues) if you have any test to be included.

## TODO

- [ ] ARM support for DockerHub ([Issue #2](https://github.com/KEINOS/Dockerfile_of_SQLite3/issues/2))

## License

- [MIT License](https://github.com/KEINOS/Dockerfile_of_SQLite3/blob/master/LICENSE.md) by [The Dockerfile of SQLite3 Contributors](https://github.com/KEINOS/Dockerfile_of_SQLite3/graphs/contributors).
  - SQLite: [Public Domain](https://sqlite.org/copyright.html) by [D. Richard Hipp](https://en.wikipedia.org/wiki/D._Richard_Hipp) and [SQLite.org](https://sqlite.org/).

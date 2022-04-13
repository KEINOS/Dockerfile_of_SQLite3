[![Container Scan](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container-analysis.yml/badge.svg)](https://github.com/KEINOS/Dockerfile_of_SQLite3/actions/workflows/container-analysis.yml "Check vulnerabilities and best practices violation")

# Dockerfile of SQLite3

Docker image of the latest SQLite3 version.

- Docker image: `keinos/sqlite3:latest`
- Repositories:
  - Image: https://hub.docker.com/r/keinos/sqlite3 @ DockerHub
  - Source: https://github.com/KEINOS/Dockerfile_of_SQLite3 @ GitHub
- Issues: https://github.com/KEINOS/Dockerfile_of_SQLite3/issues @ GitHub

## Usage

### Pull the latest image

Docker will pull the latest image when it's used. Though, you can pull (download) the latest image manually as below:

```shellsession
$ docker pull keinos/sqlite3:latest
...
```

### Interactive

Running `sqlite3` command inside the container interactively.

```shellsession
$ docker run --rm -it keinos/sqlite3
SQLite version 3.28.0 2019-04-16 19:49:53
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite>
sqlite> .quit
```

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

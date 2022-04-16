# Security Policy

## Supported Versions

Currently, only an image built from the [latest official source code](https://www.sqlite.org/src/doc/trunk/README.md) is available.

Though, as of SQLite v3.38.2, we provide version tagged Docker images.

```bash
docker pull keinos/sqlite3:3.38.2
```

## Vulnerability Policy

As a minimum security measure, we take the following:

- We use the latest `Alpine` as a base image.
- We use the [official latest released source code](https://www.sqlite.org/src/doc/trunk/README.md).
- Image Scan
  - The following services are used to check the vulnerability of the created images.
    - [Snyk Docker Action](https://github.com/snyk/actions/tree/master/docker)
    - [Azure Container Scan Action](https://github.com/Azure/container-scan) (Both Trivy and Dockle)
  - Images are scanned on:
    - push, pull request, and merge.
    - The Dockerfile is also scanned on a weekly basis.

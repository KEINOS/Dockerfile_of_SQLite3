# Security Policy

## [Fail-Fast](https://en.wikipedia.org/wiki/Fail-fast_system) Policy

The "`latest`" image will be updated within a week using the latest source code <ins>as soon as the [official source code](https://www.sqlite.org/src/doc/trunk/README.md) has been updated</ins>.

### Supported Versions

Version-tagged Docker images are available to enable a fallback. (From SQLite v3.38.2).

```bash
docker pull keinos/sqlite3:3.38.2
```

- [View Available Tags (SQLite version) ](https://hub.docker.com/r/keinos/sqlite3/tags) @ DockerHub

## Vulnerability Policy

As a minimum security measure, we take the following:

- We use the latest `Alpine` as a base image.
- We use the [official latest released source code](https://www.sqlite.org/src/doc/trunk/README.md).
- Image Scan
  - The following services are used to check the vulnerability of the created images.
    - [Snyk Docker Action](https://github.com/snyk/actions/tree/master/docker)
    - [Grype Container Scan](https://github.com/anchore/scan-action)
  - Images are scanned on:
    - push, pull request, and merge.
    - The Dockerfile is also scanned on a weekly basis.

> __Note__: As of Aug 3, 2023, [Azure Container Scan Action](https://github.com/Azure/container-scan) (for both Trivy and Dockle) is deprecated. We've replaced with [Grype Container Scan](https://github.com/anchore/scan-action).

# Security Policy

## Supported Versions

Currently, only image built from the [latest source code](https://www.sqlite.org/src/doc/trunk/README.md) is available.

Though, as of SQLite v3.38.2, we provide version tagged Docker images.

```bash
docker pull keinos/sqlite3:3.38.2
```

## Vulnerability Policy

- We use the latest `Alpine` as a base image.
- Automated Scan
  - The following services are used to check the vulnerability of the created images.
    - [Snyk Docker Action](https://github.com/snyk/actions/tree/master/docker)
    - [Azure Container Scan Action](https://github.com/Azure/container-scan) (Both Trivy and Dockle)

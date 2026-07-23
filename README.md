# 2060-io TypeScript Template

Opinionated single-app TypeScript template used by 2060-io.

## Quick Start

### Install dependencies
We use `pnpm` as the package manager. To install dependencies, run:

```bash
pnpm install
```

### Run Locally
To start the development server, use:

```bash
pnpm dev
```

### Run Checks
To ensure code quality and correctness, run the following commands:

- **Linting**:
  ```bash
  pnpm check-format
  ```

- **Type Checking**:
  ```bash
  pnpm check-types
  ```

- **Run Tests**:
  ```bash
  pnpm test
  ```

- **Run Tests in Watch Mode**:
  ```bash
  pnpm test:watch
  ```

### Build
To build the project for production, run:

```bash
pnpm build
```

### Validate
To run all checks in one command:

```bash
pnpm validate
```

## CI/CD

This template ships the standard 2060-io GitHub Actions pipeline, built on the
shared reusable workflows (`2060-linter-call`, `resolve-version-call`,
`discord-release-notify-call`). Use it as a reference for new projects and as the
baseline when upgrading existing ones.

### Continuous Integration — [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

Runs on every pull request and on pushes to `main` / `v*` branches:

- **`ci`** — reusable `2060-linter-call` job: build, format check, type check,
  unit/integration/e2e tests and conventional-commit PR-title validation.
  Helm chart linting is available via `enable-charts-lint: true` (off by default).
- **`docker-build`** — builds the Docker image (without pushing) so image
  breakage is caught in PRs.

### Continuous Deployment — [`.github/workflows/cd.yml`](.github/workflows/cd.yml)

Runs on pushes to `main`, `release/**` and `v*` branches:

1. **`resolve-version`** — reusable `resolve-version-call` decides the next
   version: **stable** releases via [release-please](https://github.com/googleapis/release-please)
   (a merged Release PR) or **dev** prereleases via semantic-release (any push
   with releasable commits).
2. **`docker`** — builds and pushes the image to Docker Hub with the resolved
   version plus the floating tags (`latest`, `dev`, `v<major>`, `v<major>.<minor>`, …).
3. **`helm`** — packages and pushes the Helm chart under [`charts/`](charts/) to
   the Docker Hub OCI registry with matching tags.
4. **`discord-notify`** — announces stable releases on Discord. A manual
   `workflow_dispatch` (input `notify_tag`) can re-announce any tag.

Versioning is driven by [`release-please-config.json`](release-please-config.json)
and [`.release-please-manifest.json`](.release-please-manifest.json).

### Maintenance branches

Besides `main`, the pipeline supports **maintenance branches** named `v1`, `v1.11`,
… which keep an older line alive while `main` moves on. Two rules make this safe:

- Dev prereleases are anchored to the branch itself (`prerelease-branch:
  ${{ github.ref_name }}`), so a maintenance branch does not reuse `main`'s
  prerelease sequence.
- **Cross-line floating tags are only published from `main`.** A release from
  `v1.11` publishes its immutable version tag and its own minor-line pointer
  (`v1.11`), but never moves `latest`, `v1`, `dev`, `v1-dev` or `v1.11-dev`
  backwards.

| Branch | Release | Tags published |
| --- | --- | --- |
| `main` | stable `v2.0.0` | `v2.0.0`, `v2.0`, `latest`, `v2` |
| `v1.11` | stable `v1.11.5` | `v1.11.5`, `v1.11` |
| `main` | dev `v2.1.0-dev.3` | `v2.1.0-dev.3`, `v2.1.0-dev`, `dev`, `v2-dev`, `v2.1-dev` |
| `v1.11` | dev `v1.11.10-dev.2` | `v1.11.10-dev.2`, `v1.11.10-dev` |

### Required repository secrets

| Secret | Used by | Purpose |
| --- | --- | --- |
| `DOCKER_HUB_LOGIN` | `cd.yml` | Docker Hub username / org (also the image & chart namespace) |
| `DOCKER_HUB_PWD` | `cd.yml` | Docker Hub access token |
| `DISCORD_UPDATES_WEBHOOK_URL` | `cd.yml` | Discord webhook for release announcements |

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

### Adapting this template to a new project

- Rename the image everywhere it is referenced: `IMAGE_NAME` in
  [`cd.yml`](.github/workflows/cd.yml), the chart directory
  `charts/2060-ts-template/` and `charts/*/Chart.yaml`, and `image.repository`
  in [`charts/2060-ts-template/values.yaml`](charts/2060-ts-template/values.yaml).
- Update the `.name` / `.fullname` / `.labels` helpers in
  `charts/<name>/templates/_helpers.tpl` to match the new chart name.
- Adjust the [`Dockerfile`](Dockerfile) if the app needs a runtime port, extra
  build artifacts or system packages. `service.enabled` in `values.yaml` exposes
  a Kubernetes Service when the app listens on a port.
- Set the starting version in `.release-please-manifest.json`.

# 2060-io TypeScript Template

Opinionated single-app TypeScript template used by 2060-io.

## Quick Start

### Install dependencies
We use `pnpm` as the package manager, pinned through the `packageManager` field. Enable Corepack once, then install:

```bash
corepack enable
pnpm install
```

### Run Locally
To start the development server, use:

```bash
pnpm dev
```

### Run Checks
To ensure code quality and correctness, run the following commands:

- **Lint and format check** (read-only, same command CI runs):
  ```bash
  pnpm check-format
  ```

- **Apply safe lint and format fixes**:
  ```bash
  pnpm fix-format
  ```

  `pnpm fix-format:unsafe` also applies Biome's unsafe fixes. Those rewrite code, for example
  deleting `console.*` calls and turning `x!.y` into `x?.y`, so review the diff before committing.

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

CI (`.github/workflows/ci.yml`) and CD (`.github/workflows/cd.yml`) both call the shared reusable
workflows in [2060-io/organization](https://github.com/2060-io/organization). Refs are pinned to a
tag-backed commit SHA with the tag in a trailing comment, and Dependabot keeps both in sync.

CD resolves the next version with release-please (`release-please-config.json` and
`.release-please-manifest.json`), then publishes what the repository actually contains:

- The `docker` job runs only if a `Dockerfile` exists at the repository root.
- The `helm` job runs only if `charts/Chart.yaml` exists.

Neither is shipped with the template, so add them in the repository generated from it. Floating tags
(`latest`, `dev`, `vN`, `vN.M-dev`) are only published from the default branch; maintenance branches
publish their own version and minor-line tags.

Required repository secrets: `DOCKER_HUB_LOGIN`, `DOCKER_HUB_PWD`, and `DISCORD_UPDATES_WEBHOOK_URL`
for release announcements.

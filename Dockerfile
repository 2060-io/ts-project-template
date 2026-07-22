# syntax=docker/dockerfile:1

# ---- Build stage ---------------------------------------------------------
# Node version is kept in sync with the 2060 reusable CI workflow (Node 24).
FROM node:24-alpine AS builder
WORKDIR /app

# Corepack activates the pnpm version pinned in package.json ("packageManager").
RUN corepack enable

# Install dependencies first so this layer is cached across source-only changes.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

# ---- Runtime stage -------------------------------------------------------
FROM node:24-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN corepack enable

# Production-only dependencies for a smaller runtime image.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

# Compiled output from the build stage.
COPY --from=builder /app/dist ./dist

USER node
CMD ["node", "dist/index.js"]

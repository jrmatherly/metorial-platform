ARG PACKAGE_NAME=@metorial/app-dashboard
ARG PACKAGE_DIRECTORY=src/frontend/apps/dashboard

FROM oven/bun:1.2.20-debian AS bun_base

# ------------------------
# BUILDER
# ------------------------
FROM bun_base AS builder

ARG PACKAGE_NAME
ARG PACKAGE_DIRECTORY
ARG METORIAL_ENV

ENV METORIAL_ENV=production

WORKDIR /app

# Copy all necessary source directories
COPY /clients ./clients

COPY /src/frontend ./src/frontend
COPY /src/backend ./src/backend
COPY /src/packages ./src/packages
COPY /src/mcp-engine ./src/mcp-engine
COPY /src/services ./src/services

# Copy root configuration files
COPY /package.json ./package.json
COPY /turbo.json ./turbo.json
COPY /bun.lock ./bun.lock

ENV NODE_OPTIONS=--max_old_space_size=6144

RUN bun install

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# Generate Prisma clients for the filtered package tree only
RUN bun turbo run prisma:generate --filter=${PACKAGE_NAME}... --concurrency=1 --log-prefix=task

# Build only the frontend app and its dependencies (not entire monorepo)
# The "..." suffix means "this package and all packages it depends on"
RUN bun turbo run build --filter=${PACKAGE_NAME}... --concurrency=1 --log-prefix=task

RUN bun turbo run frontend:build --filter=${PACKAGE_NAME} --concurrency=1 --log-prefix=task

# ------------------------
# SERVER SETUP
# ------------------------
FROM bun_base AS server_setup

WORKDIR /app

# Create a simple server package.json
RUN cat <<'EOF' > package.json
{
  "name": "frontend-server",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

RUN bun install

# Create the server file
RUN cat <<'EOF' > server.js
import express from "express";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3300;
const distPath = join(__dirname, "dist");

// Serve static files from dist directory
app.use(express.static(distPath));

// Catch-all route to serve index.html for client-side routing
app.get("*", (req, res) => {
  res.sendFile(join(distPath, "index.html"));
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Frontend server running on port ${PORT}`);
});
EOF

# ------------------------
# RUNNER
# ------------------------
FROM bun_base AS runner

WORKDIR /app

ARG PACKAGE_DIRECTORY
ARG PACKAGE_NAME

ENV NODE_ENV=production
ENV TZ=UTC
ENV PACKAGE_DIRECTORY=${PACKAGE_DIRECTORY}
ENV PACKAGE_NAME=${PACKAGE_NAME}

ENV PORT=3300
EXPOSE 3300

RUN apt-get update && apt-get install -y --no-install-recommends curl wget ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the built frontend files from builder
COPY --from=builder "/app/${PACKAGE_DIRECTORY}/dist" ./dist

# Copy the server setup from server_setup stage
COPY --from=server_setup /app/node_modules ./node_modules
COPY --from=server_setup /app/server.js ./server.js
COPY --from=server_setup /app/package.json ./package.json

CMD ["bun", "run", "server.js"]

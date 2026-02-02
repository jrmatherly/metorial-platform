# Frontend Dockerfile using pre-built dist folder
# Build the frontend locally first: bun turbo run frontend:build --filter=@metorial/app-dashboard
# Then run: docker build -f deployment/dockerfiles/frontend-prebuilt.Dockerfile -t metorial-frontend:local .

FROM oven/bun:1.2.20-debian AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV TZ=UTC
ENV PORT=3300

EXPOSE 3300

RUN apt-get update && apt-get install -y --no-install-recommends curl wget ca-certificates && rm -rf /var/lib/apt/lists/*

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

# Copy the pre-built frontend files
COPY /src/frontend/apps/dashboard/dist ./dist

CMD ["bun", "run", "server.js"]

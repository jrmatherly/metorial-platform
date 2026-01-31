# Metorial Platform

Core platform: API server, React frontend, Go MCP engine.

## Build & Test

```bash
bun run build         # Build all packages (Turbo)
bun run dev           # Development mode
bun run test          # Run tests
```

## Database (Prisma)

```bash
bun run prisma:generate   # Generate client
bun run prisma:push       # Push schema changes
```

## Structure

| Directory | Purpose |
|-----------|---------|
| `src/backend/` | API server and business logic |
| `src/frontend/` | React dashboard |
| `src/mcp-engine/` | Go MCP engine (see its AGENTS.md) |
| `src/services/` | Microservices |
| `src/packages/` | Shared packages |

## Tech Stack

- **Runtime**: Bun + Turbo
- **Frontend**: React, TypeScript
- **Backend**: TypeScript, Prisma
- **Engine**: Go 1.24 (see `src/mcp-engine/AGENTS.md`)
- **Databases**: PostgreSQL, MongoDB (logs), Redis (cache)

## Conventions

- TypeScript strict mode
- Use Turbo for builds (`turbo run build`)
- Prisma for database schema

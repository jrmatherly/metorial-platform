# MCP Engine

High-performance Go-based MCP connection engine.

## Build & Test

```bash
make build-unified    # Build main binary
make dev              # Hot reload with air
make test             # Run tests
make lint             # golangci-lint v2
make proto            # Generate protobuf
```

## Requirements

- Go 1.24+
- golangci-lint v2 (config: `.golangci.yml`)

## Structure

| Directory | Purpose |
|-----------|---------|
| `cmd/` | Entry points |
| `internal/` | Private packages |
| `pkg/` | Public packages |
| `pkg/proto-mcp-manager/` | Generated protobuf (excluded from lint) |

## Conventions

- Follow Go idioms
- golangci-lint v2 enforced (style checks relaxed for existing code)
- Protobuf files in `pkg/proto-mcp-manager/`
- Vendor directory excluded from analysis

## Known Technical Debt

Style checks temporarily disabled in `.golangci.yml`:
- ST1000: Package comments
- ST1003: Naming conventions (sessionId→sessionID)
- ST1016: Receiver name consistency
- ST1020: Comment format

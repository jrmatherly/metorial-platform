-- Metorial Self-Hosting Database Initialization
-- This script runs automatically on first PostgreSQL start

-- Create engine database for MCP Engine service
CREATE DATABASE engine;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE engine TO postgres;

-- Log completion
\echo 'Database initialization complete: postgres, engine'

# Plugin Dockerfiles for Canopy Auto-Update

This directory contains Dockerfiles for running Canopy nodes with different plugin implementations. Each Dockerfile is optimized for a specific plugin runtime and supports automatic plugin updates from GitHub releases.

## Available Dockerfiles

| Dockerfile | Plugin | Runtime | Description |
|------------|--------|---------|-------------|
| `Dockerfile.go` | Go | Native binary | Compiled Go plugin |
| `Dockerfile.python` | Python | Python 3.x + venv | Python plugin with auto-venv setup |
| `Dockerfile.typescript` | TypeScript | Node.js 18 | TypeScript/JavaScript plugin |
| `Dockerfile.kotlin` | Kotlin | OpenJDK 21 | Kotlin/JVM plugin |
| `Dockerfile.csharp` | C# | .NET 8.0 | C#/.NET plugin |

## Prerequisites

For the auto-update system to work with plugins, you must configure the following in your Canopy config file:

### Required Configuration

```json
{
  "auto_update": {
    "enabled": true,
    "plugin": {
      "enabled": true,
      "owner": "your-github-org",
      "repo": "your-plugin-repo",
      "asset_name": "plugin-name.tar.gz"
    }
  }
}
```

### Configuration Fields

| Field | Description | Example |
|-------|-------------|---------|
| `auto_update.enabled` | Enable auto-update for CLI | `true` |
| `auto_update.plugin.enabled` | **Required: Enable plugin auto-update** | `true` |
| `auto_update.plugin.owner` | GitHub repository owner | `"canopy-network"` |
| `auto_update.plugin.repo` | GitHub repository name | `"canopy"` |
| `auto_update.plugin.asset_name` | Release asset filename | See table below |

### Asset Names by Plugin Type

| Plugin | Asset Name (x64) | Asset Name (ARM64) |
|--------|------------------|-------------------|
| Go | `go-plugin-linux-amd64.tar.gz` | `go-plugin-linux-arm64.tar.gz` |
| Python | `python-plugin.tar.gz` | `python-plugin.tar.gz` |
| TypeScript | `typescript-plugin.tar.gz` | `typescript-plugin.tar.gz` |
| Kotlin | `kotlin-plugin.tar.gz` | `kotlin-plugin.tar.gz` |
| C# | `csharp-plugin-linux-x64.tar.gz` | `csharp-plugin-linux-arm64.tar.gz` |

## Usage

### 1. Update docker-compose.yaml

Point to the Dockerfile for your desired plugin:

```yaml
services:
  node1:
    build:
      context: ../docker_image
      dockerfile: ./plugins/Dockerfile.python  # Change to your plugin
      args:
        BRANCH: main  # or 'latest' for latest tag
```

### 2. Set Environment Variables

Create a `.env` file with required configuration:

```bash
# Plugin configuration
PLUGIN_TYPE=python
PLUGIN_OWNER=your-org
PLUGIN_REPO=your-repo
PLUGIN_ASSET=python-plugin.tar.gz
```

### 3. Build and Run

```bash
docker-compose build --no-cache node1
docker-compose up node1
```

## How Auto-Update Works

1. **On startup**: The Dockerfile only includes `pluginctl.sh` (no plugin code)
2. **First run**: Auto-updater downloads the latest plugin release from GitHub
3. **Extraction**: `pluginctl.sh` extracts the tarball and sets up dependencies
4. **Runtime setup**: Language-specific setup runs (e.g., Python creates venv)
5. **Periodic checks**: Auto-updater checks for new releases every 30 minutes (configurable)
6. **Updates**: When a new version is found, it downloads and restarts the plugin

## Plugin-Specific Notes

### Python
- Virtual environment (`.venv`) is created automatically on first start
- Dependencies are installed from `pyproject.toml`
- Dependencies are reinstalled after each update

### TypeScript
- `node_modules` is included in the release tarball
- `package.json` is required for ES module support

### Kotlin
- Requires JRE 21 or later
- Uses fat JAR with all dependencies included

### C#
- Requires .NET 8.0 runtime
- Uses framework-dependent deployment (not self-contained)

### Go
- Native binary, no runtime dependencies
- Architecture-specific builds (amd64/arm64)

## Troubleshooting

### Check plugin logs

```bash
docker-compose exec node1 cat /tmp/plugin/<plugin>-plugin.log
```

Replace `<plugin>` with: `go`, `python`, `typescript`, `kotlin`, or `csharp`

### Check if plugin is running

```bash
docker-compose exec node1 /app/plugin/<plugin>/pluginctl.sh status
```

### Force plugin restart

```bash
docker-compose exec node1 /app/plugin/<plugin>/pluginctl.sh restart
```

### Check extracted files

```bash
docker-compose exec node1 ls -la /app/plugin/<plugin>/
```

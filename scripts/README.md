# Scripts Directory - Unix Philosophy Tools

The `scripts/` directory contains focused, composable utilities that follow the Unix philosophy of "do one thing and do it well." These tools are designed to be scriptable, pipeable, and work together to accomplish complex tasks.

## Unix Philosophy Implementation

Each script in this directory follows these principles:
1. **Single Purpose**: Does one job well
2. **Clean Output**: Separates data from decoration
3. **Pipeable**: Output can be input to other programs
4. **Scriptable**: Non-interactive by default
5. **Composable**: Works with other tools

## Core System Tools

### `omnixy-check-system`
**Purpose**: System requirements validation
**What it does**:
- Verifies NixOS installation
- Checks user permissions
- Validates system prerequisites

**Usage**:
```bash
# Check everything
./omnixy-check-system

# Check only NixOS
./omnixy-check-system --nixos-only

# Check permissions only
./omnixy-check-system --permissions-only

# Silent check for scripting
./omnixy-check-system --quiet

# JSON output
OMNIXY_JSON=1 ./omnixy-check-system
```

**Exit Codes**:
- 0: All checks passed
- 1: Critical failure (not NixOS, etc.)

**Output Modes**:
- Default: Human-readable status
- `--quiet`: No output, just exit codes
- `--json`: Machine-readable JSON

### `omnixy-backup-config`
**Purpose**: Configuration backup management
**What it does**:
- Creates timestamped backups of `/etc/nixos`
- Outputs backup location for scripting
- Handles non-existent configurations gracefully

**Usage**:
```bash
# Default backup with timestamp
backup_path=$(./omnixy-backup-config)

# Specify backup location
./omnixy-backup-config /custom/backup/path

# Get help
./omnixy-backup-config --help
```

**Output**:
- Prints backup directory path to stdout
- Can be captured and used by other scripts

### `omnixy-install-files`
**Purpose**: File installation management
**What it does**:
- Copies configuration files to destination
- Sets proper permissions
- Handles directory creation

**Usage**:
```bash
# Install from current directory to /etc/nixos
./omnixy-install-files

# Specify source and destination
./omnixy-install-files /path/to/source /path/to/dest

# Get help
./omnixy-install-files --help
```

**Features**:
- Automatic permission setting
- Directory creation
- Error handling

### `omnixy-configure-user`
**Purpose**: User configuration management
**What it does**:
- Updates system configuration with username
- Modifies both system and home configurations
- Validates username format

**Usage**:
```bash
# Interactive mode (prompts for username)
username=$(./omnixy-configure-user)

# Non-interactive mode
./omnixy-configure-user alice

# Specify configuration files
./omnixy-configure-user alice /etc/nixos/configuration.nix /etc/nixos/home.nix

# Get help
./omnixy-configure-user --help
```

**Validation**:
- Username must start with letter
- Can contain letters, numbers, underscore, dash
- Outputs the configured username

### `omnixy-build-system`
**Purpose**: System building and switching
**What it does**:
- Builds NixOS configuration
- Switches to new configuration
- Supports dry-run testing

**Usage**:
```bash
# Build and switch system
./omnixy-build-system

# Build specific configuration
./omnixy-build-system /path/to/config custom-config

# Dry run (test only)
./omnixy-build-system --dry-run

# Get help
./omnixy-build-system --help
```

**Modes**:
- Default: Build and switch to configuration
- `--dry-run`: Test build without switching
- Quiet mode: Minimal output for scripting

## Tool Composition Examples

These tools are designed to work together:

### Complete Installation Pipeline
```bash
#!/bin/bash
# Automated OmniXY installation

# Check system prerequisites
./scripts/omnixy-check-system || exit 1

# Backup existing configuration
backup_path=$(./scripts/omnixy-backup-config)
echo "Backup created: $backup_path"

# Install new configuration
./scripts/omnixy-install-files

# Configure user
username=$(./scripts/omnixy-configure-user "$USER")
echo "Configured for user: $username"

# Test build first
./scripts/omnixy-build-system --dry-run
echo "Configuration test passed"

# Apply changes
./scripts/omnixy-build-system
echo "System updated successfully"
```

### Backup and Restore Workflow
```bash
#!/bin/bash
# Backup current config and test new one

# Create backup
backup=$(./scripts/omnixy-backup-config)

# Install new config
./scripts/omnixy-install-files /path/to/new/config

# Test new config
if ! ./scripts/omnixy-build-system --dry-run; then
    echo "New config failed, restoring backup"
    ./scripts/omnixy-install-files "$backup" /etc/nixos
    exit 1
fi

echo "New configuration validated"
```

## Environment Variables

These tools respect the following environment variables:

### `OMNIXY_QUIET`
When set to `1`, tools produce minimal output suitable for scripting:
```bash
export OMNIXY_QUIET=1
./scripts/omnixy-check-system  # No output, just exit code
```

### `OMNIXY_JSON`
When set to `1`, tools output JSON where applicable:
```bash
export OMNIXY_JSON=1
./scripts/omnixy-check-system  # JSON status output
```

## Integration with Main Installer

The main `install-simple.sh` script uses these tools:

```bash
# From install-simple.sh
scripts/omnixy-check-system
backup_path=$(scripts/omnixy-backup-config)
scripts/omnixy-install-files
username=$(scripts/omnixy-configure-user "$username")
scripts/omnixy-build-system --dry-run  # if dry run mode
scripts/omnixy-build-system           # actual installation
```

## Error Handling

All scripts follow consistent error handling:
- Exit code 0 for success
- Exit code 1 for failures
- Error messages to stderr
- Data output to stdout

Example error handling:
```bash
if ! ./scripts/omnixy-check-system --quiet; then
    echo "System check failed" >&2
    exit 1
fi
```

## Adding New Tools

When adding new Unix philosophy tools:

1. **Single Purpose**: One job per script
2. **Help Option**: `--help` flag with usage info
3. **Error Handling**: Proper exit codes and stderr
4. **Environment Variables**: Respect `OMNIXY_QUIET` and `OMNIXY_JSON`
5. **Documentation**: Clear purpose and usage examples
6. **Testing**: Verify with various inputs and edge cases

## Design Principles

These tools embody:

**Composability**: Tools work together through pipes and command chaining

**Reliability**: Consistent interfaces and error handling

**Scriptability**: Non-interactive operation with clear outputs

**Maintainability**: Simple, focused implementations

**Testability**: Each tool can be tested in isolation

This approach makes the OmniXY installation and management system both powerful and maintainable while following time-tested Unix design principles.
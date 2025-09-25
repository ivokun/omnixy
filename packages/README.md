# Packages Directory - Custom Nix Packages

The `packages/` directory contains custom Nix package definitions for OmniXY-specific tools and utilities. These packages are built and distributed through the Nix package manager as part of the OmniXY system.

## Package Architecture

Each package follows the standard Nix packaging format:
```nix
{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  # Package definition
  # ...

  meta = with lib; {
    description = "Package description";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
```

## Current Packages

### `scripts.nix`
**Purpose**: OmniXY utility scripts package
**What it contains**: All the management and utility scripts for OmniXY system

**Generated Scripts**:

#### System Management
- `omnixy`: Main command interface with `--quiet` and `--json` modes
- `omnixy-update`: System and flake updates with progress indication
- `omnixy-clean`: Garbage collection and store optimization
- `omnixy-rebuild`: Wrapper for `nixos-rebuild switch`

#### Theme Management
- `omnixy-theme-set`: Set system theme with validation
- `omnixy-theme-list`: List available themes (plain/JSON output)
- `omnixy-theme-get`: Get current theme (scriptable output)

#### Package Management
- `omnixy-search`: Search Nix packages
- `omnixy-install`: Package installation guide

#### Development Tools
- `omnixy-dev-shell`: Language-specific development shells
  - Supports: rust, go, python, node/js, c/cpp

#### Utilities
- `omnixy-screenshot`: Screenshot tool with region/window/full modes
- `omnixy-info`: System information with JSON/quiet modes
- `omnixy-help`: Comprehensive help system

**Build Process**:
1. Creates all scripts in `installPhase`
2. Sets executable permissions
3. Patches interpreter paths
4. Validates script syntax

**Dependencies**:
- `bash`: Shell interpreter
- `coreutils`: Basic Unix utilities
- `gnugrep`, `gnused`, `gawk`: Text processing
- `jq`: JSON processing
- `curl`, `wget`: Network utilities
- `git`: Version control
- `fzf`, `ripgrep`: Search tools

### `plymouth-theme.nix` (Commented Out)
**Purpose**: Plymouth boot theme package
**Status**: Disabled until fully implemented
**What it would contain**: Custom boot splash theme for OmniXY

## Package Integration

### Flake Integration
Packages are exported in `flake.nix`:
```nix
packages.${system} = {
  omnixy-scripts = pkgs.callPackage ./packages/scripts.nix {};
  # Additional packages...
};
```

### System Installation
Scripts package is installed system-wide in the main configuration, making all utilities available in PATH.

### Development Access
Packages can be built individually for testing:
```bash
# Build scripts package
nix build .#omnixy-scripts

# Test individual script
./result/bin/omnixy --help
```

## Script Features

### Unix Philosophy Compliance
All scripts follow Unix principles:

**Clean Output Separation**:
```bash
# Human-readable (default)
omnixy info

# Machine-readable
omnixy --json info | jq .system.version

# Scriptable
omnixy --quiet update && echo "Updated successfully"
```

**Composability**:
```bash
# Theme management pipeline
current_theme=$(omnixy --quiet theme get)
omnixy theme list --quiet | grep -v "$current_theme" | head -1 | xargs omnixy theme set
```

**Error Handling**:
- Exit codes: 0 for success, 1 for failure
- Errors to stderr, data to stdout
- Graceful handling of missing files/permissions

### Environment Variables
Scripts respect global settings:

- `OMNIXY_QUIET=1`: Minimal output mode
- `OMNIXY_JSON=1`: JSON output where applicable

### Theme System Integration
Theme scripts provide complete theme management:
- List all 11 available themes
- Get current theme for scripting
- Set theme with validation and rebuild
- Support for both interactive and automated usage

### Development Environment Support
Development scripts provide:
- Quick access to language-specific environments
- Consistent tooling across languages
- Integration with system configuration

## Adding New Packages

To add a new package:

1. **Create Package File**:
```nix
# packages/my-tool.nix
{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  # Package definition
}
```

2. **Add to Flake**:
```nix
# In flake.nix packages section
my-tool = pkgs.callPackage ./packages/my-tool.nix {};
```

3. **Install in System**:
```nix
# In configuration or module
environment.systemPackages = with pkgs; [
  # ... other packages
  my-tool
];
```

## Package Categories

### System Utilities
Tools for managing the OmniXY system itself:
- Configuration management
- System updates and maintenance
- Backup and restore operations

### User Interface Tools
Scripts for desktop and user interaction:
- Theme management
- Screenshot utilities
- Information display

### Development Aids
Tools for software development:
- Environment management
- Build and deployment helpers
- Debug and diagnostic tools

### Integration Scripts
Utilities for integrating with external systems:
- Cloud services
- Version control
- Package repositories

## Build System

### Derivation Structure
Each package is a Nix derivation with:
- **Inputs**: Dependencies and build tools
- **Build Process**: How to create the package
- **Outputs**: Resulting files and executables
- **Metadata**: Description, license, platforms

### Build Phases
For script packages:
1. **Setup**: Prepare build environment
2. **Install**: Create scripts and set permissions
3. **Fixup**: Patch interpreters and validate
4. **Package**: Create final Nix store paths

### Quality Assurance
- Syntax checking during build
- Interpreter path patching
- Permission validation
- Dependency verification

## Testing and Validation

### Build Testing
```bash
# Test package builds correctly
nix build .#omnixy-scripts

# Validate all scripts are created
ls result/bin/ | wc -l

# Test script functionality
result/bin/omnixy --help
```

### Integration Testing
```bash
# Test in clean environment
nix develop --command bash -c "omnixy-info --json | jq .system"

# Test cross-script integration
nix develop --command bash -c "omnixy theme list --quiet | head -1 | xargs echo"
```

This packaging system provides a robust foundation for distributing and managing OmniXY utilities while maintaining the reproducibility and reliability of the Nix ecosystem.
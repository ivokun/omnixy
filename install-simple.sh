#!/usr/bin/env bash
# Simple, Unix-philosophy compliant installer
# Does one thing: installs OmniXY configuration
set -e

show_usage() {
    cat << 'EOF'
Usage: install-simple.sh [options]

Options:
  --user USERNAME     Set username (default: prompt)
  --theme THEME       Set theme (default: tokyo-night)
  --quiet, -q         Quiet operation
  --dry-run, -n       Test configuration without switching
  --help, -h          Show this help

Environment:
  OMNIXY_QUIET=1      Enable quiet mode
  OMNIXY_USER         Default username
  OMNIXY_THEME        Default theme

Examples:
  ./install-simple.sh --user alice --theme gruvbox
  ./install-simple.sh --quiet --dry-run
  OMNIXY_USER=bob ./install-simple.sh

This installer follows Unix philosophy:
- Does one job: install configuration
- Accepts arguments instead of interactive prompts
- Produces clean, pipeable output
- Can be scripted and automated
EOF
}

main() {
    local username="${OMNIXY_USER:-}"
    local theme="${OMNIXY_THEME:-tokyo-night}"
    local quiet=false
    local dry_run=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                username="$2"
                shift 2
                ;;
            --theme)
                theme="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
                export OMNIXY_QUIET=1
                shift
                ;;
            --dry-run|-n)
                dry_run=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done

    # Make scripts executable
    chmod +x scripts/omnixy-* 2>/dev/null || true

    # Step 1: Check system (exit early if problems)
    [[ "$quiet" != "true" ]] && echo "Checking system requirements..."
    scripts/omnixy-check-system

    # Step 2: Backup existing config
    [[ "$quiet" != "true" ]] && echo "Backing up configuration..."
    backup_path=$(scripts/omnixy-backup-config)
    [[ "$quiet" != "true" ]] && echo "Backup created: $backup_path"

    # Step 3: Install files
    [[ "$quiet" != "true" ]] && echo "Installing configuration files..."
    scripts/omnixy-install-files

    # Step 4: Configure user
    if [[ -n "$username" ]]; then
        [[ "$quiet" != "true" ]] && echo "Configuring user: $username"
        scripts/omnixy-configure-user "$username"
    else
        [[ "$quiet" != "true" ]] && echo "Configuring user..."
        username=$(scripts/omnixy-configure-user)
    fi

    # Step 5: Set theme
    if [[ "$theme" != "tokyo-night" ]]; then
        [[ "$quiet" != "true" ]] && echo "Setting theme: $theme"
        sudo sed -i "s/currentTheme = \".*\"/currentTheme = \"$theme\"/" /etc/nixos/configuration.nix
    fi

    # Step 6: Build system
    if [[ "$dry_run" == "true" ]]; then
        [[ "$quiet" != "true" ]] && echo "Testing configuration (dry run)..."
        scripts/omnixy-build-system --dry-run
        echo "Configuration test successful. Run without --dry-run to apply."
    else
        [[ "$quiet" != "true" ]] && echo "Building system configuration..."
        scripts/omnixy-build-system

        [[ "$quiet" != "true" ]] && cat << EOF

✅ OmniXY installation complete!

User: $username
Theme: $theme
Backup: $backup_path

Reboot to ensure all changes take effect.
EOF
    fi
}

main "$@"
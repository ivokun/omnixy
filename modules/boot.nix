{ config, pkgs, lib, ... }:

# OmniXY Boot Configuration
# Plymouth theming and seamless boot experience

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };

  # Import our custom Plymouth theme package
  #plymouth-themes = pkgs.plymouth;
  plymouth-themes = pkgs.callPackage ../packages/plymouth-theme.nix {};
in
{
  config = mkIf (cfg.enable or true) {
    # Plymouth boot splash configuration
    boot.plymouth = {
      enable = true;
      theme = "omnixy-${cfg.theme}";
      themePackages = [ plymouth-themes ];

      # Logo configuration
      logo = "${plymouth-themes}/share/plymouth/themes/omnixy-${cfg.theme}/logo.png";
    };

    # Boot optimization and theming
    boot = {
      # Kernel parameters for smooth boot
      kernelParams = [
        # Quiet boot (suppress most messages)
        "quiet"
        # Splash screen
        "splash"
        # Reduce log level
        "loglevel=3"
        # Disable systemd status messages on console
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        # Faster boot
        "boot.shell_on_fail"
        # Hide cursor
        "vt.global_cursor_default=0"
        # Security: Disable emergency shell access
        "systemd.debug-shell=0"
      ];

      # Console configuration for seamless experience
      consoleLogLevel = 0;

      # Boot loader configuration
      loader = {
        # Timeout for boot menu
        timeout = 3;

        # systemd-boot theme integration
        systemd-boot = {
          editor = false;  # Disable editor for security
          configurationLimit = 10;
          consoleMode = "auto";
        };
      };

      # Initial ramdisk optimization
      initrd = {
        systemd.enable = true;
        verbose = false;

        # Include Plymouth in initrd
        includeDefaultModules = true;
      };
    };

    # Systemd service for seamless login transition
    systemd.services.omnixy-boot-transition = {
      description = "OmniXY Boot Transition Service";
      after = [ "plymouth-start.service" "display-manager.service" ];
      before = [ "plymouth-quit.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.plymouth}/bin/plymouth quit --retain-splash";
        TimeoutStartSec = "10s";
      };

      script = ''
        # Ensure smooth transition from Plymouth to display manager
        ${pkgs.coreutils}/bin/sleep 1

        # Send welcome message
        ${pkgs.plymouth}/bin/plymouth message --text="Loading OmniXY ${cfg.theme} theme..."
        ${pkgs.coreutils}/bin/sleep 2

        # Signal that boot is complete
        ${pkgs.plymouth}/bin/plymouth message --text="System Ready"
      '';
    };

    # Theme switching integration
    environment.systemPackages = [
      plymouth-themes

      # Plymouth theme switching script
      (omnixy.makeScript "omnixy-plymouth-theme" "Switch Plymouth boot theme" ''
        if [ -z "$1" ]; then
          echo "🎨 Current Plymouth theme: omnixy-${cfg.theme}"
          echo
          echo "Available themes:"
          ls ${plymouth-themes}/share/plymouth/themes/ | grep "omnixy-" | sed 's/omnixy-/  - /'
          echo
          echo "Usage: omnixy-plymouth-theme <theme-name>"
          exit 0
        fi

        THEME="omnixy-$1"
        THEME_PATH="${plymouth-themes}/share/plymouth/themes/$THEME"

        if [ ! -d "$THEME_PATH" ]; then
          echo "❌ Theme '$1' not found!"
          echo "Available themes:"
          ls ${plymouth-themes}/share/plymouth/themes/ | grep "omnixy-" | sed 's/omnixy-/  - /'
          exit 1
        fi

        echo "🎨 Setting Plymouth theme to: $1"

        # Update Plymouth theme
        sudo ${pkgs.plymouth}/bin/plymouth-set-default-theme "$THEME"

        # Regenerate initrd
        echo "🔄 Regenerating initrd..."
        sudo nixos-rebuild boot --flake /etc/nixos#omnixy

        echo "✅ Plymouth theme updated!"
        echo "⚠️  Reboot to see the new boot theme"
      '')

      # Plymouth management utilities
      (omnixy.makeScript "omnixy-boot-preview" "Preview Plymouth theme" ''
        if [ "$EUID" -ne 0 ]; then
          echo "❌ This command must be run as root (use sudo)"
          exit 1
        fi

        echo "🎬 Starting Plymouth preview..."
        echo "   Press Ctrl+Alt+F1 to return to console"
        echo "   Press Ctrl+C to stop preview"

        # Kill any running Plymouth instances
        pkill plymouthd 2>/dev/null || true

        # Start Plymouth in preview mode
        ${pkgs.plymouth}/bin/plymouthd --debug --debug-file=/tmp/plymouth-debug.log
        ${pkgs.plymouth}/bin/plymouth --show-splash

        # Simulate boot progress
        for i in $(seq 0 5 100); do
          ${pkgs.plymouth}/bin/plymouth --update="boot-progress:$i/100"
          sleep 0.1
        done

        echo "Plymouth preview running. Check another TTY to see the splash screen."
        echo "Press Enter to stop..."
        read -r

        ${pkgs.plymouth}/bin/plymouth --quit
        pkill plymouthd 2>/dev/null || true

        echo "✅ Plymouth preview stopped"
      '')

      # Boot diagnostics
      (omnixy.makeScript "omnixy-boot-info" "Show boot information and diagnostics" ''
        echo "🚀 OmniXY Boot Information"
        echo "═══════════════════════════"
        echo

        echo "🎨 Plymouth Configuration:"
        echo "  Current Theme: ${cfg.theme}"
        echo "  Theme Package: ${plymouth-themes}"
        echo "  Plymouth Status: $(systemctl is-active plymouth-start.service 2>/dev/null || echo 'inactive')"
        echo

        echo "⚙️  Boot Configuration:"
        echo "  Boot Loader: $(bootctl status 2>/dev/null | grep 'systemd-boot' || echo 'systemd-boot')"
        echo "  Kernel: $(uname -r)"
        echo "  Boot Time: $(systemd-analyze | head -1)"
        echo

        echo "📊 Boot Performance:"
        systemd-analyze blame | head -10
        echo

        echo "🔧 Boot Services:"
        echo "  Display Manager: $(systemctl is-active display-manager 2>/dev/null || echo 'inactive')"
        echo "  Plymouth: $(systemctl is-active plymouth-*.service 2>/dev/null || echo 'inactive')"
        echo "  OmniXY Transition: $(systemctl is-active omnixy-boot-transition 2>/dev/null || echo 'inactive')"

        if [ -f "/tmp/plymouth-debug.log" ]; then
          echo
          echo "🐛 Plymouth Debug Log (last 10 lines):"
          tail -10 /tmp/plymouth-debug.log
        fi
      '')
    ];

    # Ensure Plymouth themes are properly installed
    system.activationScripts.plymouthThemes = ''
      # Ensure Plymouth theme directory exists
      mkdir -p /run/current-system/sw/share/plymouth/themes

      # Set default theme on first boot
      if [ ! -f /var/lib/plymouth/theme ]; then
        mkdir -p /var/lib/plymouth
        echo "omnixy-${cfg.theme}" > /var/lib/plymouth/theme

        # Set the theme
        ${pkgs.plymouth}/bin/plymouth-set-default-theme "omnixy-${cfg.theme}" || true
      fi
    '';

    # Font configuration for Plymouth
    fonts = {
      packages = with pkgs; [
        jetbrains-mono
        cantarell-fonts
        liberation_ttf
        dejavu_fonts
      ];

      # Ensure fonts are available early in boot
      fontDir.enable = true;
    };

    # Security settings are now included in boot.kernelParams above

    # Optional: LUKS integration for encrypted systems
    # Plymouth will automatically handle LUKS password prompts when LUKS devices are configured

    # Console and TTY configuration
    console = {
      earlySetup = true;
      colors = [
        # Custom console color palette matching current theme
        # This will be used before Plymouth starts
      ] ++ (
        if cfg.theme == "tokyo-night" then [
          "1a1b26" "f7768e" "9ece6a" "e0af68"
          "7aa2f7" "bb9af7" "7dcfff" "c0caf5"
          "414868" "f7768e" "9ece6a" "e0af68"
          "7aa2f7" "bb9af7" "7dcfff" "a9b1d6"
        ] else if cfg.theme == "gruvbox" then [
          "282828" "cc241d" "98971a" "d79921"
          "458588" "b16286" "689d6a" "a89984"
          "928374" "fb4934" "b8bb26" "fabd2f"
          "83a598" "d3869b" "8ec07c" "ebdbb2"
        ] else []
      );
    };
  };
}

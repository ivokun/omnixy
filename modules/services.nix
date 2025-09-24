{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omarchy;
in
{
  # System services configuration
  services = {
    # Display server
    xserver = {
      enable = true;

      # Display Manager
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };

        defaultSession = "hyprland";
      };

      # Touchpad support
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
        };
      };

      # Keyboard layout
      xkb = {
        layout = "us";
        variant = "";
        options = "caps:escape,compose:ralt";
      };
    };

    # Printing support
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        hplip
        epson-escpr
        epson-escpr2
      ];
    };

    # Scanner support
    sane = {
      enable = true;
      extraBackends = with pkgs; [
        sane-airscan
        epkowa
      ];
    };

    # Sound
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # Network
    resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1"
        "8.8.8.8"
        "1.0.0.1"
        "8.8.4.4"
      ];
    };

    # Bluetooth
    blueman.enable = true;

    # Power management
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
    };

    # System monitoring
    smartd = {
      enable = true;
      autodetect = true;
    };

    # File indexing and search
    locate = {
      enable = true;
      interval = "daily";
      package = pkgs.plocate;
      localuser = null;
    };

    # Backup service (optional)
    restic = {
      backups = {
        # Example backup configuration
        # home = {
        #   paths = [ "/home/${cfg.user}" ];
        #   repository = "/backup/restic";
        #   passwordFile = "/etc/restic/password";
        #   timerConfig = {
        #     OnCalendar = "daily";
        #     Persistent = true;
        #   };
        #   pruneOpts = [
        #     "--keep-daily 7"
        #     "--keep-weekly 4"
        #     "--keep-monthly 12"
        #   ];
        # };
      };
    };

    # SSH daemon
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
    };

    # Firewall
    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;
    };

    # System maintenance
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Scheduled tasks
    cron = {
      enable = true;
      systemCronJobs = [
        # Example: Update system database daily
        # "0 3 * * * root ${pkgs.nix-index}/bin/nix-index"
      ];
    };

    # Syncthing for file synchronization
    syncthing = {
      enable = false; # Set to true to enable
      user = cfg.user;
      dataDir = "/home/${cfg.user}/Documents";
      configDir = "/home/${cfg.user}/.config/syncthing";
    };

    # Tailscale VPN
    tailscale = {
      enable = false; # Set to true to enable
      useRoutingFeatures = "client";
    };

    # Flatpak support
    flatpak.enable = true;

    # GVFS for mounting and trash support
    gvfs.enable = true;

    # Thumbnail generation
    tumbler.enable = true;

    # Notification daemon is handled by mako in Hyprland config

    # System daemons
    dbus = {
      enable = true;
      packages = with pkgs; [ dconf ];
    };

    # Avahi for network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # ACPI daemon for power management
    acpid.enable = true;

    # Automatic upgrades (disabled by default)
    # system.autoUpgrade = {
    #   enable = true;
    #   allowReboot = false;
    #   dates = "04:00";
    #   flake = "/etc/nixos#omarchy";
    # };

    # Earlyoom - out of memory killer
    earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      freeSwapThreshold = 10;
    };

    # Logrotate
    logrotate = {
      enable = true;
      settings = {
        "/var/log/omarchy/*.log" = {
          frequency = "weekly";
          rotate = 4;
          compress = true;
          delaycompress = true;
          notifempty = true;
          create = "644 root root";
        };
      };
    };
  };

  # Systemd services
  systemd = {
    # User session environment
    user.extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/home/${cfg.user}/.nix-profile/bin:/etc/profiles/per-user/${cfg.user}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';

    # Automatic cleanup
    timers.clear-tmp = {
      description = "Clear /tmp weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    services.clear-tmp = {
      description = "Clear /tmp directory";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/find /tmp -type f -atime +7 -delete";
      };
    };

    # Custom Omarchy services
    services.omarchy-init = {
      description = "Omarchy initialization service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "omarchy-init" ''
          #!/usr/bin/env bash
          echo "Initializing Omarchy..."

          # Create necessary directories
          mkdir -p /var/log/omarchy
          mkdir -p /var/lib/omarchy
          mkdir -p /etc/omarchy

          # Set up initial configuration
          if [ ! -f /etc/omarchy/initialized ]; then
            echo "$(date): Omarchy initialized" > /etc/omarchy/initialized
            echo "Welcome to Omarchy!" > /etc/motd
          fi
        '';
      };
    };
  };

  # Security policies
  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        /* Allow members of wheel group to manage systemd services without password */
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    # AppArmor
    apparmor = {
      enable = true;
      packages = with pkgs; [
        apparmor-utils
        apparmor-profiles
      ];
    };
  };
}
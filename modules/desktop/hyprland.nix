{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.omnixy.desktop;
in
{
  options.omnixy.desktop = {
    enable = mkEnableOption "OmniXY Hyprland desktop environment";

    monitors = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "DP-1,1920x1080@144,0x0,1" ];
      description = "Monitor configuration for Hyprland";
    };

    defaultTerminal = mkOption {
      type = types.str;
      default = "ghostty";
      description = "Default terminal emulator";
    };

    defaultBrowser = mkOption {
      type = types.str;
      default = "firefox";
      description = "Default web browser";
    };

    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to wallpaper image (optional)";
    };
  };

  config = mkIf (cfg.enable or true) {
    # Enable Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # XDG portal for Wayland
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # Session variables
    environment.sessionVariables = {
      # Wayland specific
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";

      # Default applications
      TERMINAL = cfg.defaultTerminal;
      BROWSER = cfg.defaultBrowser;
      EDITOR = "nvim";
    };

    # Essential packages for Hyprland
    environment.systemPackages = with pkgs; [
      # Core Wayland utilities
      wayland
      wayland-protocols
      wayland-utils
      wlroots

      # Hyprland ecosystem
      hyprland-protocols
      hyprpaper
      hyprlock
      hypridle
      hyprpicker

      # Status bar and launcher
      waybar
      wofi
      rofi-wayland
      walker

      # Notification daemon
      mako
      libnotify

      # Clipboard
      wl-clipboard
      cliphist
      copyq

      # Screen management
      wlr-randr
      kanshi
      nwg-displays

      # Screenshots and recording
      grim
      slurp
      swappy
      wf-recorder

      # System tray and applets
      networkmanagerapplet
      blueman
      pasystray

      # Wallpaper managers
      swww
      swaybg
      wpaperd

      # File managers
      nautilus
      thunar
      pcmanfm
      ranger
      yazi

      # Polkit agent
      polkit_gnome

      # Themes and cursors
      gnome.adwaita-icon-theme
      papirus-icon-theme
      bibata-cursors
      capitaine-cursors
    ];

    # Create Hyprland config directory structure
    system.activationScripts.hyprlandConfig = ''
      mkdir -p /etc/omnixy/hyprland

      # Main Hyprland configuration
      cat > /etc/omnixy/hyprland/hyprland.conf <<'EOF'
      # Omarchy Hyprland Configuration
      # See https://wiki.hyprland.org/Configuring/

      # Monitor configuration
      ${concatStringsSep "\n" (map (m: "monitor = ${m}") cfg.monitors)}
      monitor = ,preferred,auto,1

      # Execute on startup
      exec-once = waybar
      exec-once = mako
      exec-once = swww init
      exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store
      exec-once = nm-applet --indicator
      exec-once = blueman-applet

      # Set wallpaper
      exec = swww img ${toString cfg.wallpaper} --transition-type wipe

      # Input configuration
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options = caps:escape
          kb_rules =

          follow_mouse = 1
          mouse_refocus = false

          touchpad {
              natural_scroll = true
              disable_while_typing = true
              tap-to-click = true
              scroll_factor = 0.5
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification
      }

      # General configuration
      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(7aa2f7ee) rgba(c4a7e7ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = dwindle
          allow_tearing = false
      }

      # Decoration
      decoration {
          rounding = 10

          blur {
              enabled = true
              size = 6
              passes = 2
              new_optimizations = true
              ignore_opacity = true
          }

          drop_shadow = true
          shadow_range = 20
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)

          dim_inactive = false
          dim_strength = 0.1
      }

      # Animations
      animations {
          enabled = true

          bezier = overshot, 0.05, 0.9, 0.1, 1.05
          bezier = smoothOut, 0.5, 0, 0.99, 0.99
          bezier = smoothIn, 0.5, -0.5, 0.68, 1.5

          animation = windows, 1, 5, overshot, slide
          animation = windowsOut, 1, 4, smoothOut, slide
          animation = windowsIn, 1, 4, smoothIn, slide
          animation = windowsMove, 1, 4, default
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      # Layouts
      dwindle {
          pseudotile = true
          preserve_split = true
          force_split = 2
      }

      master {
          new_is_master = true
      }

      # Gestures
      gestures {
          workspace_swipe = true
          workspace_swipe_fingers = 3
          workspace_swipe_distance = 300
          workspace_swipe_invert = true
      }

      # Misc
      misc {
          force_default_wallpaper = 0
          disable_hyprland_logo = true
          disable_splash_rendering = true
          mouse_move_enables_dpms = true
          key_press_enables_dpms = true
          enable_swallow = true
          swallow_regex = ^(ghostty|alacritty|kitty|footclient)$
      }

      # Window rules
      windowrulev2 = opacity 0.9 override 0.9 override, class:^(ghostty|Alacritty|kitty)$
      windowrulev2 = opacity 0.9 override 0.9 override, class:^(Code|code-oss)$
      windowrulev2 = float, class:^(pavucontrol|nm-connection-editor|blueman-manager)$
      windowrulev2 = float, class:^(org.gnome.Calculator|gnome-calculator)$
      windowrulev2 = float, title:^(Picture-in-Picture)$
      windowrulev2 = pin, title:^(Picture-in-Picture)$
      windowrulev2 = float, class:^(imv|mpv|vlc)$
      windowrulev2 = center, class:^(imv|mpv|vlc)$

      # Workspace rules
      workspace = 1, monitor:DP-1, default:true
      workspace = 2, monitor:DP-1
      workspace = 3, monitor:DP-1
      workspace = 4, monitor:DP-1
      workspace = 5, monitor:DP-1
      workspace = 6, monitor:HDMI-A-1
      workspace = 7, monitor:HDMI-A-1
      workspace = 8, monitor:HDMI-A-1
      workspace = 9, monitor:HDMI-A-1
      workspace = 10, monitor:HDMI-A-1

      # Key bindings
      $mainMod = SUPER

      # Application shortcuts
      bind = $mainMod, Return, exec, ${cfg.defaultTerminal}
      bind = $mainMod, B, exec, ${cfg.defaultBrowser}
      bind = $mainMod, E, exec, nautilus
      bind = $mainMod, D, exec, walker
      bind = $mainMod SHIFT, D, exec, wofi --show drun
      bind = $mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

      # Window management
      bind = $mainMod, Q, killactive
      bind = $mainMod, F, fullscreen, 1
      bind = $mainMod SHIFT, F, fullscreen, 0
      bind = $mainMod, Space, togglefloating
      bind = $mainMod, P, pseudo
      bind = $mainMod, J, togglesplit
      bind = $mainMod, G, togglegroup
      bind = $mainMod, Tab, changegroupactive

      # Focus movement
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Window movement
      bind = $mainMod SHIFT, h, movewindow, l
      bind = $mainMod SHIFT, l, movewindow, r
      bind = $mainMod SHIFT, k, movewindow, u
      bind = $mainMod SHIFT, j, movewindow, d

      # Workspace switching
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move to workspace
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through workspaces
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Resize mode
      bind = $mainMod, R, submap, resize
      submap = resize
      binde = , h, resizeactive, -10 0
      binde = , l, resizeactive, 10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10
      bind = , escape, submap, reset
      submap = reset

      # Screenshot bindings
      bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
      bind = SHIFT, Print, exec, grim - | swappy -f -
      bind = $mainMod, Print, exec, grim -g "$(slurp)" - | wl-copy

      # Media keys
      binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl previous
      bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

      # System control
      bind = $mainMod SHIFT, Q, exit
      bind = $mainMod SHIFT, R, exec, hyprctl reload
      bind = $mainMod SHIFT, L, exec, hyprlock
      bind = $mainMod SHIFT, P, exec, systemctl poweroff
      bind = $mainMod SHIFT, B, exec, systemctl reboot

      # Mouse bindings
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      EOF
    '';

    # Waybar configuration
    home-manager.users.${config.omnixy.user or "user"} = {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = [{
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "network" "bluetooth" "pulseaudio" "backlight" "battery" "tray" ];

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              urgent = "";
              default = "";
            };
          };

          "hyprland/window" = {
            max-length = 50;
            separate-outputs = true;
          };

          clock = {
            format = " {:%H:%M}";
            format-alt = " {:%A, %B %d, %Y (%R)}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
          };

          network = {
            format-wifi = " {essid}";
            format-ethernet = " {ifname}";
            format-disconnected = "⚠ Disconnected";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          };

          bluetooth = {
            format = " {status}";
            format-connected = " {device_alias}";
            format-connected-battery = " {device_alias} {device_battery_percentage}%";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = [ "" "" "" "" "" "" "" "" "" ];
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-icons = [ "" "" "" "" "" ];
          };

          tray = {
            icon-size = 16;
            spacing = 10;
          };
        }];

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
          }

          window#waybar {
            background: rgba(30, 30, 46, 0.9);
            color: #cdd6f4;
          }

          #workspaces button {
            padding: 0 5px;
            background: transparent;
            color: #cdd6f4;
            border-bottom: 3px solid transparent;
          }

          #workspaces button.active {
            background: rgba(203, 166, 247, 0.2);
            border-bottom: 3px solid #cba6f7;
          }

          #clock,
          #battery,
          #cpu,
          #memory,
          #temperature,
          #backlight,
          #network,
          #pulseaudio,
          #tray,
          #bluetooth {
            padding: 0 10px;
            margin: 0 5px;
          }

          #battery.charging {
            color: #a6e3a1;
          }

          #battery.warning:not(.charging) {
            color: #fab387;
          }

          #battery.critical:not(.charging) {
            color: #f38ba8;
            animation: blink 0.5s linear infinite alternate;
          }

          @keyframes blink {
            to {
              background-color: #f38ba8;
              color: #1e1e2e;
            }
          }
        '';
      };
    };
  };
}
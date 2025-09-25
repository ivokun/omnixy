{ config, pkgs, lib, ... }:

# Hyprland idle management configuration for OmniXY
# Handles screen locking, power management, and idle behavior

with lib;

let
  cfg = config.omnixy.desktop;
  omnixy = import ../../helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Install required packages
    environment.systemPackages = with pkgs; [
      hypridle
      hyprlock
      hyprpicker
      brightnessctl
    ];

    # Create hypridle configuration
    environment.etc."omnixy/hyprland/hypridle.conf".text = ''
      # OmniXY Idle Management Configuration

      general {
          # Avoid starting multiple hyprlock instances
          lock_cmd = pidof hyprlock || hyprlock

          # Lock before suspend
          before_sleep_cmd = loginctl lock-session

          # Lock when lid is closed
          before_sleep_cmd = hyprlock

          # Unlock when lid is opened
          after_sleep_cmd = hyprctl dispatch dpms on
      }

      # Dim screen after 5 minutes
      listener {
          timeout = 300
          on-timeout = brightnessctl -s set 10%
          on-resume = brightnessctl -r
      }

      # Lock screen after 10 minutes
      listener {
          timeout = 600
          on-timeout = loginctl lock-session
      }

      # Turn off screen after 15 minutes
      listener {
          timeout = 900
          on-timeout = hyprctl dispatch dpms off
          on-resume = hyprctl dispatch dpms on
      }

      # Suspend system after 30 minutes (optional - can be disabled)
      ${optionalString (cfg.idleSuspend or false) ''
        listener {
            timeout = 1800
            on-timeout = systemctl suspend
        }
      ''}
    '';

    # Create hyprlock configuration
    environment.etc."omnixy/hyprland/hyprlock.conf".text = ''
      # OmniXY Screen Lock Configuration

      general {
          disable_loading_bar = true
          grace = 5
          hide_cursor = false
          no_fade_in = false
      }

      background {
          monitor =
          path = ${if cfg.wallpaper != null then toString cfg.wallpaper else "~/Pictures/wallpaper.jpg"}
          blur_passes = 3
          blur_size = 8
          noise = 0.0117
          contrast = 0.8916
          brightness = 0.8172
          vibrancy = 0.1696
          vibrancy_darkness = 0.0
      }

      # User avatar
      image {
          monitor =
          path = ~/.face
          size = 150
          rounding = -1
          border_size = 4
          border_color = rgb(221, 221, 221)
          rotate = 0
          reload_time = -1
          reload_cmd =
          position = 0, 200
          halign = center
          valign = center
      }

      # Current time
      label {
          monitor =
          text = cmd[update:30000] echo "$TIME"
          color = rgba(200, 200, 200, 1.0)
          font_size = 55
          font_family = JetBrainsMono Nerd Font
          position = -100, -40
          halign = right
          valign = bottom
          shadow_passes = 5
          shadow_size = 10
      }

      # Date
      label {
          monitor =
          text = cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"
          color = rgba(200, 200, 200, 1.0)
          font_size = 25
          font_family = JetBrainsMono Nerd Font
          position = -100, -150
          halign = right
          valign = bottom
          shadow_passes = 5
          shadow_size = 10
      }

      # Password input field
      input-field {
          monitor =
          size = 200, 50
          outline_thickness = 3
          dots_size = 0.33
          dots_spacing = 0.15
          dots_center = false
          dots_rounding = -1
          outer_color = rgb(151515)
          inner_color = rgb(200, 200, 200)
          font_color = rgb(10, 10, 10)
          fade_on_empty = true
          fade_timeout = 1000
          placeholder_text = <i>Input Password...</i>
          hide_input = false
          rounding = -1
          check_color = rgb(204, 136, 34)
          fail_color = rgb(204, 34, 34)
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          fail_timeout = 2000
          fail_transitions = 300
          capslock_color = -1
          numlock_color = -1
          bothlock_color = -1
          invert_numlock = false
          swap_font_color = false
          position = 0, -20
          halign = center
          valign = center
      }

      # User name
      label {
          monitor =
          text = ${config.omnixy.user or "user"}
          color = rgba(200, 200, 200, 1.0)
          font_size = 20
          font_family = JetBrainsMono Nerd Font
          position = 0, 80
          halign = center
          valign = center
          shadow_passes = 5
          shadow_size = 10
      }

      # System info
      label {
          monitor =
          text = cmd[update:60000] echo "$(uname -n)"
          color = rgba(200, 200, 200, 0.8)
          font_size = 16
          font_family = JetBrainsMono Nerd Font
          position = 100, 40
          halign = left
          valign = bottom
          shadow_passes = 5
          shadow_size = 10
      }
    '';
  };
}
{ config, pkgs, lib, ... }:

# Hyprland autostart configuration for OmniXY
# Handles application startup and initialization

with lib;

let
  cfg = config.omnixy.desktop;
  omnixy = import ../../helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Create autostart configuration
    environment.etc."omnixy/hyprland/autostart.conf".text = ''
      # OmniXY Autostart Configuration
      # Applications and services to start with Hyprland

      # Essential services
      exec-once = waybar
      exec-once = mako
      exec-once = swww init
      exec-once = nm-applet --indicator
      exec-once = blueman-applet

      # Wallpaper setup
      ${optionalString (cfg.wallpaper != null) ''exec = swww img ${toString cfg.wallpaper} --transition-type wipe''}

      # Clipboard management
      exec-once = wl-paste --type text --watch cliphist store
      exec-once = wl-paste --type image --watch cliphist store

      # Authentication agent
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

      # Audio setup
      ${optionalString (omnixy.isEnabled "media") ''
        exec-once = easyeffects --gapplication-service
      ''}

      # Gaming-specific autostart
      ${optionalString (omnixy.isEnabled "gaming") ''
        exec-once = mangohud
        exec-once = gamemode
      ''}

      # Development-specific autostart
      ${optionalString (omnixy.isEnabled "coding") ''
        exec-once = ${pkgs.vscode}/bin/code --no-sandbox
      ''}

      # Communication apps
      ${optionalString (omnixy.isEnabled "communication") ''
        exec-once = discord --start-minimized
        exec-once = slack --start-minimized
      ''}

      # System monitoring (optional)
      ${optionalString (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") ''
        exec-once = ${pkgs.btop}/bin/btop --utf-force
      ''}

      # Screenshots directory
      exec-once = mkdir -p ~/Pictures/Screenshots

      # Idle management
      exec-once = hypridle

      # OSD for volume/brightness
      exec-once = swayosd-server
    '';
  };
}
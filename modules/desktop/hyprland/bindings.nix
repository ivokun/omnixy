{ config, pkgs, lib, ... }:

# Hyprland keybindings configuration for OmniXY
# Comprehensive keyboard shortcuts for productivity

with lib;

let
  cfg = config.omnixy.desktop;
  omnixy = import ../../helpers.nix { inherit config pkgs lib; };
in
{
  config = mkIf (cfg.enable or true) {
    # Create keybindings configuration
    environment.etc."omnixy/hyprland/bindings.conf".text = ''
      # OmniXY Hyprland Keybindings
      # Comprehensive keyboard shortcuts

      # Variables for commonly used applications
      $terminal = ${cfg.defaultTerminal or "ghostty"}
      $browser = ${cfg.defaultBrowser or "firefox"}
      $filemanager = thunar
      $menu = walker

      # Modifier keys
      $mainMod = SUPER

      # Window management
      bind = $mainMod, Q, killactive
      bind = $mainMod, M, exit
      bind = $mainMod, V, togglefloating
      bind = $mainMod, P, pseudo # dwindle
      bind = $mainMod, J, togglesplit # dwindle
      bind = $mainMod, F, fullscreen

      # Application launches
      bind = $mainMod, Return, exec, $terminal
      bind = $mainMod, E, exec, $filemanager
      bind = $mainMod, R, exec, $menu
      bind = $mainMod, B, exec, $browser

      # Development shortcuts
      ${optionalString (omnixy.isEnabled "coding") ''
        bind = $mainMod, C, exec, code
        bind = $mainMod SHIFT, C, exec, $terminal -e nvim
        bind = $mainMod, G, exec, $terminal -e lazygit
        bind = $mainMod SHIFT, G, exec, github-desktop
      ''}

      # Communication shortcuts
      ${optionalString (omnixy.isEnabled "communication") ''
        bind = $mainMod, D, exec, discord
        bind = $mainMod SHIFT, D, exec, slack
        bind = $mainMod, T, exec, telegram-desktop
      ''}

      # Media shortcuts
      ${optionalString (omnixy.isEnabled "media") ''
        bind = $mainMod, S, exec, spotify
        bind = $mainMod SHIFT, S, exec, $terminal -e cmus
        bind = $mainMod, I, exec, imv
        bind = $mainMod SHIFT, I, exec, gimp
      ''}

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # Move focus with mainMod + vim keys
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Move windows with mainMod + SHIFT + arrow keys
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d

      # Move windows with mainMod + SHIFT + vim keys
      bind = $mainMod SHIFT, h, movewindow, l
      bind = $mainMod SHIFT, l, movewindow, r
      bind = $mainMod SHIFT, k, movewindow, u
      bind = $mainMod SHIFT, j, movewindow, d

      # Switch workspaces with mainMod + [0-9]
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

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
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

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Resize windows
      bind = $mainMod CTRL, left, resizeactive, -50 0
      bind = $mainMod CTRL, right, resizeactive, 50 0
      bind = $mainMod CTRL, up, resizeactive, 0 -50
      bind = $mainMod CTRL, down, resizeactive, 0 50

      # Resize windows with vim keys
      bind = $mainMod CTRL, h, resizeactive, -50 0
      bind = $mainMod CTRL, l, resizeactive, 50 0
      bind = $mainMod CTRL, k, resizeactive, 0 -50
      bind = $mainMod CTRL, j, resizeactive, 0 50

      # Screenshots
      bind = , Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')
      bind = SHIFT, Print, exec, grim ~/Pictures/Screenshots/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')
      bind = $mainMod, Print, exec, grim -g "$(slurp)" - | wl-copy

      # Screen recording
      bind = $mainMod SHIFT, R, exec, wf-recorder -g "$(slurp)" -f ~/Videos/recording_$(date +'%Y-%m-%d-%H%M%S.mp4')

      # Media keys
      bindl = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindl = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

      # Brightness keys
      bindl = , XF86MonBrightnessUp, exec, brightnessctl set 10%+
      bindl = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

      # Media player keys
      bindl = , XF86AudioPlay, exec, playerctl play-pause
      bindl = , XF86AudioNext, exec, playerctl next
      bindl = , XF86AudioPrev, exec, playerctl previous

      # Lock screen
      bind = $mainMod, L, exec, hyprlock

      # System controls
      bind = $mainMod SHIFT, Q, exec, wlogout
      bind = $mainMod ALT, R, exec, systemctl --user restart waybar
      bind = $mainMod ALT, W, exec, killall waybar && waybar

      # Clipboard management
      bind = $mainMod, Y, exec, cliphist list | walker --dmenu | cliphist decode | wl-copy

      # Color picker
      bind = $mainMod SHIFT, C, exec, hyprpicker -a

      # Special workspace (scratchpad)
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Game mode toggle
      ${optionalString (omnixy.isEnabled "gaming") ''
        bind = $mainMod, F1, exec, gamemoderun
      ''}

      # Theme cycling (if multiple wallpapers available)
      bind = $mainMod ALT, T, exec, omnixy-theme-bg-next
      bind = $mainMod ALT SHIFT, T, exec, omnixy-theme-next
    '';
  };
}
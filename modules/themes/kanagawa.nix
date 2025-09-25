{ config, pkgs, lib, ... }:

# Kanagawa theme for OmniXY
# A dark colorscheme inspired by the colors of the famous painting by Katsushika Hokusai

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Kanagawa color palette
  colors = {
    # Background colors
    bg = "#1f1f28";        # Dark background (sumiInk0)
    bg_dark = "#16161d";   # Darker background (sumiInk1)
    bg_light = "#2a2a37";  # Lighter background (sumiInk3)
    bg_visual = "#2d4f67"; # Visual selection (waveBlue1)

    # Foreground colors
    fg = "#dcd7ba";        # Main foreground (fujiWhite)
    fg_dim = "#c8c093";    # Dimmed foreground (fujiGray)
    fg_reverse = "#223249"; # Reverse foreground (waveBlue2)

    # Wave colors (blues)
    wave_blue1 = "#2d4f67"; # Dark blue
    wave_blue2 = "#223249"; # Darker blue
    wave_aqua1 = "#6a9589"; # Aqua green
    wave_aqua2 = "#7aa89f"; # Light aqua

    # Autumn colors (reds, oranges, yellows)
    autumn_red = "#c34043";   # Red
    autumn_orange = "#dca561"; # Orange
    autumn_yellow = "#c0a36e"; # Yellow
    autumn_green = "#76946a";  # Green

    # Spring colors (greens)
    spring_blue = "#7e9cd8";   # Blue
    spring_violet1 = "#957fb8"; # Violet
    spring_violet2 = "#b8b4d0"; # Light violet
    spring_green = "#98bb6c";   # Green

    # Ronin colors (grays)
    ronin_yellow = "#ff9e3b"; # Bright orange/yellow
    dragon_blue = "#658594";   # Muted blue
    old_white = "#c8c093";     # Old paper white

    # Special colors
    samurai_red = "#e82424";   # Bright red for errors
    ronin_gray = "#727169";    # Gray for comments
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/kanagawa/1-kanagawa.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(dcd7ba)
            col.inactive_border = rgba(2a2a37aa)
        }
        decoration {
            col.shadow = rgba(1f1f28ee)
        }

        # Kanagawa backdrop is too strong for default opacity
        windowrule = opacity 0.98 0.95, tag:terminal
      '';

      # GTK theme
      programs.dconf.enable = true;

      # Environment variables for consistent theming
      environment.variables = {
        GTK_THEME = "Adwaita-dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";
        OMNIXY_THEME_COLORS_BG = colors.bg;
        OMNIXY_THEME_COLORS_FG = colors.fg;
        OMNIXY_THEME_COLORS_ACCENT = colors.spring_blue;
      };

      # Console colors
      console = {
        colors = [
          colors.bg_dark        # black
          colors.autumn_red     # red
          colors.autumn_green   # green
          colors.autumn_yellow  # yellow
          colors.spring_blue    # blue
          colors.spring_violet1 # magenta
          colors.wave_aqua1     # cyan
          colors.old_white      # white
          colors.ronin_gray     # bright black
          colors.samurai_red    # bright red
          colors.spring_green   # bright green
          colors.ronin_yellow   # bright yellow
          colors.spring_blue    # bright blue
          colors.spring_violet2 # bright magenta
          colors.wave_aqua2     # bright cyan
          colors.fg             # bright white
        ];
      };
    }

    # User-specific theme configuration
    (omnixy.forUser {
      # GTK configuration
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      # Qt theming
      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };

      # Kitty terminal theme
      programs.kitty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        themeFile = "Kanagawa";
        settings = {
          background = colors.bg;
          foreground = colors.fg;
          selection_background = colors.bg_visual;
          selection_foreground = colors.fg;

          # Cursor colors
          cursor = colors.fg;
          cursor_text_color = colors.bg;

          # URL underline color when hovering
          url_color = colors.spring_blue;

          # Tab colors
          active_tab_background = colors.spring_blue;
          active_tab_foreground = colors.bg;
          inactive_tab_background = colors.bg_light;
          inactive_tab_foreground = colors.fg_dim;

          # Window border colors
          active_border_color = colors.spring_blue;
          inactive_border_color = colors.ronin_gray;
        };
      };

      # Alacritty terminal theme
      programs.alacritty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        settings = {
          colors = {
            primary = {
              background = colors.bg;
              foreground = colors.fg;
            };
            cursor = {
              text = colors.bg;
              cursor = colors.fg;
            };
            normal = {
              black = colors.bg_dark;
              red = colors.autumn_red;
              green = colors.autumn_green;
              yellow = colors.autumn_yellow;
              blue = colors.spring_blue;
              magenta = colors.spring_violet1;
              cyan = colors.wave_aqua1;
              white = colors.old_white;
            };
            bright = {
              black = colors.ronin_gray;
              red = colors.samurai_red;
              green = colors.spring_green;
              yellow = colors.ronin_yellow;
              blue = colors.spring_blue;
              magenta = colors.spring_violet2;
              cyan = colors.wave_aqua2;
              white = colors.fg;
            };
          };
        };
      };

      # Waybar theme
      programs.waybar = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 13px;
            border: none;
            border-radius: 0;
            min-height: 0;
          }

          window#waybar {
            background: ${colors.bg};
            color: ${colors.fg};
            border-bottom: 2px solid ${colors.spring_blue};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.fg_dim};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.spring_blue};
            border-bottom-color: ${colors.spring_blue};
          }

          #workspaces button:hover {
            color: ${colors.fg};
            background: ${colors.bg_light};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.bg_light};
            color: ${colors.fg};
          }

          #battery.critical {
            color: ${colors.samurai_red};
          }

          #battery.warning {
            color: ${colors.ronin_yellow};
          }
        '';
      };

      # Rofi theme
      programs.rofi = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        theme = {
          "*" = {
            background-color = mkLiteral colors.bg;
            foreground-color = mkLiteral colors.fg;
            border-color = mkLiteral colors.spring_blue;
            separatorcolor = mkLiteral colors.bg_light;
            scrollbar-handle = mkLiteral colors.spring_blue;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.spring_blue;
            text-color = mkLiteral colors.bg;
          };
        };
      };

      # Mako notification theme
      services.mako = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        settings = {
          font = "JetBrainsMono Nerd Font 10";
          background-color = colors.bg;
          text-color = colors.fg;
          border-color = colors.spring_blue;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.spring_blue;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Kanagawa";
          "workbench.preferredDarkColorTheme" = "Kanagawa";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=dark
          colorscheme kanagawa
        '';
        plugins = with pkgs.vimPlugins; [
          kanagawa-nvim
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Monokai Extended";

      # btop theme - using kanagawa-inspired theme
      programs.btop.settings.color_theme = "tokyo-night";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.bg_visual ];
          selectedRangeBgColor = [ colors.bg_visual ];
        };
      };

      # Zsh/shell prompt colors
      programs.starship = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          character = {
            success_symbol = "[➜](bold ${colors.spring_green})";
            error_symbol = "[➜](bold ${colors.samurai_red})";
          };
          directory = {
            style = "bold ${colors.spring_blue}";
          };
          git_branch = {
            style = "bold ${colors.spring_violet1}";
          };
          git_status = {
            style = "bold ${colors.autumn_yellow}";
          };
        };
      };
    })
  ]);
}
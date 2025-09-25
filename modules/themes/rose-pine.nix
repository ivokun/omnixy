{ config, pkgs, lib, ... }:

# Rose Pine theme for OmniXY
# All natural pine, faux fur and a bit of soho vibes for the classy minimalist

with lib;

let
  cfg = config.omnixy;
  omnixy = import ../helpers.nix { inherit config pkgs lib; };

  # Rose Pine color palette
  colors = {
    # Base colors
    base = "#191724";      # Dark background
    surface = "#1f1d2e";   # Surface background
    overlay = "#26233a";   # Overlay background
    muted = "#6e6a86";     # Muted foreground
    subtle = "#908caa";    # Subtle foreground
    text = "#e0def4";      # Main foreground
    love = "#eb6f92";      # Love (pink/red)
    gold = "#f6c177";      # Gold (yellow)
    rose = "#ebbcba";      # Rose (peach)
    pine = "#31748f";      # Pine (blue)
    foam = "#9ccfd8";      # Foam (cyan)
    iris = "#c4a7e7";      # Iris (purple)

    # Highlight colors
    highlight_low = "#21202e";
    highlight_med = "#403d52";
    highlight_high = "#524f67";
  };

in
{
  config = mkIf (cfg.enable or true) (mkMerge [
    # System-level theme configuration
    {
      # Set theme wallpaper
      omnixy.desktop.wallpaper = ./wallpapers/rose-pine/1-rose-pine.jpg;

      # Hyprland theme colors (from omarchy)
      environment.etc."omnixy/hyprland/theme.conf".text = ''
        general {
            col.active_border = rgb(575279)
            col.inactive_border = rgba(26233aaa)
        }
        decoration {
            col.shadow = rgba(191724ee)
        }
      '';

      # GTK theme
      programs.dconf.enable = true;

      # Environment variables for consistent theming
      environment.variables = {
        GTK_THEME = "Adwaita-dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";
        OMNIXY_THEME_COLORS_BG = colors.base;
        OMNIXY_THEME_COLORS_FG = colors.text;
        OMNIXY_THEME_COLORS_ACCENT = colors.foam;
      };

      # Console colors
      console = {
        colors = [
          colors.overlay     # black
          colors.love        # red
          colors.pine        # green (using pine as green alternative)
          colors.gold        # yellow
          colors.foam        # blue (using foam as blue)
          colors.iris        # magenta
          colors.rose        # cyan (using rose as cyan)
          colors.text        # white
          colors.muted       # bright black
          colors.love        # bright red
          colors.pine        # bright green
          colors.gold        # bright yellow
          colors.foam        # bright blue
          colors.iris        # bright magenta
          colors.rose        # bright cyan
          colors.text        # bright white
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
        themeFile = "Rosé Pine";
        settings = {
          background = colors.base;
          foreground = colors.text;
          selection_background = colors.surface;
          selection_foreground = colors.text;

          # Cursor colors
          cursor = colors.text;
          cursor_text_color = colors.base;

          # URL underline color when hovering
          url_color = colors.foam;

          # Tab colors
          active_tab_background = colors.foam;
          active_tab_foreground = colors.base;
          inactive_tab_background = colors.surface;
          inactive_tab_foreground = colors.subtle;

          # Window border colors
          active_border_color = colors.foam;
          inactive_border_color = colors.muted;
        };
      };

      # Alacritty terminal theme
      programs.alacritty = mkIf (omnixy.isEnabled "coding" || omnixy.isEnabled "media") {
        enable = true;
        settings = {
          colors = {
            primary = {
              background = colors.base;
              foreground = colors.text;
            };
            cursor = {
              text = colors.base;
              cursor = colors.text;
            };
            normal = {
              black = colors.overlay;
              red = colors.love;
              green = colors.pine;
              yellow = colors.gold;
              blue = colors.foam;
              magenta = colors.iris;
              cyan = colors.rose;
              white = colors.text;
            };
            bright = {
              black = colors.muted;
              red = colors.love;
              green = colors.pine;
              yellow = colors.gold;
              blue = colors.foam;
              magenta = colors.iris;
              cyan = colors.rose;
              white = colors.text;
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
            background: ${colors.base};
            color: ${colors.text};
            border-bottom: 2px solid ${colors.foam};
          }

          #workspaces button {
            padding: 0 8px;
            background: transparent;
            color: ${colors.subtle};
            border-bottom: 2px solid transparent;
          }

          #workspaces button.active {
            color: ${colors.foam};
            border-bottom-color: ${colors.foam};
          }

          #workspaces button:hover {
            color: ${colors.text};
            background: ${colors.surface};
          }

          #clock, #battery, #cpu, #memory, #network, #pulseaudio {
            padding: 0 10px;
            margin: 0 2px;
            background: ${colors.surface};
            color: ${colors.text};
          }

          #battery.critical {
            color: ${colors.love};
          }

          #battery.warning {
            color: ${colors.gold};
          }
        '';
      };

      # Rofi theme
      programs.rofi = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        theme = {
          "*" = {
            background-color = mkLiteral colors.base;
            foreground-color = mkLiteral colors.text;
            border-color = mkLiteral colors.foam;
            separatorcolor = mkLiteral colors.surface;
            scrollbar-handle = mkLiteral colors.foam;
          };

          "#window" = {
            border = mkLiteral "2px";
            border-radius = mkLiteral "8px";
            padding = mkLiteral "20px";
          };

          "#element selected" = {
            background-color = mkLiteral colors.foam;
            text-color = mkLiteral colors.base;
          };
        };
      };

      # Mako notification theme
      services.mako = mkIf (omnixy.isEnabled "media" || omnixy.isEnabled "gaming") {
        enable = true;
        settings = {
          font = "JetBrainsMono Nerd Font 10";
          background-color = colors.base;
          text-color = colors.text;
          border-color = colors.foam;
          border-size = 2;
          border-radius = 8;
          padding = "10";
          margin = "5";
          default-timeout = 5000;
          progress-color = colors.foam;
        };
      };

      # VSCode theme
      programs.vscode = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        userSettings = {
          "workbench.colorTheme" = "Rosé Pine";
          "workbench.preferredDarkColorTheme" = "Rosé Pine";
          "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Droid Sans Mono', 'monospace'";
          "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };

      # Neovim theme
      programs.neovim = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        extraConfig = ''
          set background=dark
          colorscheme rose-pine
        '';
        plugins = with pkgs.vimPlugins; [
          rose-pine
        ];
      };

      # Git diff and bat theme
      programs.bat.config.theme = "Monokai Extended";

      # btop theme - using a rose-inspired theme
      programs.btop.settings.color_theme = "rose-pine";

      # Lazygit theme
      programs.lazygit.settings = {
        gui.theme = {
          lightTheme = false;
          selectedLineBgColor = [ colors.surface ];
          selectedRangeBgColor = [ colors.surface ];
        };
      };

      # Zsh/shell prompt colors
      programs.starship = mkIf (omnixy.isEnabled "coding") {
        enable = true;
        settings = {
          format = "$directory$git_branch$git_status$character";
          character = {
            success_symbol = "[➜](bold ${colors.pine})";
            error_symbol = "[➜](bold ${colors.love})";
          };
          directory = {
            style = "bold ${colors.foam}";
          };
          git_branch = {
            style = "bold ${colors.iris}";
          };
          git_status = {
            style = "bold ${colors.gold}";
          };
        };
      };
    })
  ]);
}
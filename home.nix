{ config, pkgs, lib, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "user"; # Change this to your username
  home.homeDirectory = "/home/user"; # Change this to your home directory

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # Terminal utilities
    ghostty
    alacritty
    kitty
    wezterm
    starship

    # File management
    ranger
    yazi
    xplr

    # Development tools
    neovim
    vscode
    lazygit
    gh
    git-lfs
    delta

    # System monitoring
    btop
    htop
    nvtopPackages.full

    # Media
    mpv
    imv
    ffmpeg

    # Browsers
    firefox
    chromium
    brave

    # Communication
    discord
    slack
    telegram-desktop

    # Productivity
    obsidian
    zathura
    libreoffice

    # CLI tools
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide
    jq
    yq
    httpie
    curl
    wget

    # Screenshot and recording
    grim
    slurp
    wf-recorder
    swappy

    # Wayland tools
    wl-clipboard
    wlr-randr
    wev

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name"; # Change this
    userEmail = "your.email@example.com"; # Change this

    delta = {
      enable = true;
      options = {
        features = "decorations";
        side-by-side = true;
        navigate = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit -m";
      lg = "log --graph --oneline --decorate";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      merge.conflictStyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;

    shellAliases = {
      ll = "eza -la";
      ls = "eza";
      l = "eza -lah";
      tree = "eza --tree";

      ".." = "cd ..";
      "..." = "cd ../..";

      g = "git";
      lg = "lazygit";

      cat = "bat";
      grep = "rg";
      find = "fd";

      # NixOS specific
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#omnixy";
      update = "nix flake update";
      clean = "nix-collect-garbage -d";

      # OmniXY specific
      omnixy-theme = "omnixy-theme-set";
      omnixy-update = "omnixy-update";
    };

    initExtra = ''
      # Initialize starship prompt
      eval "$(starship init bash)"

      # Initialize zoxide
      eval "$(zoxide init bash)"

      # Set up fzf
      source ${pkgs.fzf}/share/fzf/key-bindings.bash
      source ${pkgs.fzf}/share/fzf/completion.bash

      # Custom prompt for nix-shell
      if [ -n "$IN_NIX_SHELL" ]; then
        export PS1="[nix-shell] $PS1"
      fi
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        [╭─](bold green)$username[@](bold yellow)$hostname [in ](bold white)$directory$git_branch$git_status$cmd_duration
        [╰─](bold green)$character
      '';

      character = {
        success_symbol = lib.mkDefault "[➜](bold green)";
        error_symbol = lib.mkDefault "[➜](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = lib.mkDefault "bold cyan";
      };

      git_branch = {
        style = lib.mkDefault "bold purple";
        symbol = " ";
      };

      git_status = {
        style = lib.mkDefault "bold red";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };

      cmd_duration = {
        min_time = 500;
        format = " took [$duration](bold yellow)";
      };
    };
  };

  # Alacritty terminal
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; };
        opacity = 0.95;
        decorations = "none";
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 12.0;
      };

      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # LazyVim will handle most plugins
      lazy-nvim
    ];

    extraConfig = ''
      " Bootstrap LazyVim
      lua require("config.lazy")
    '';
  };

  # Firefox
  programs.firefox = {
    enable = true;

    profiles.default = {
      settings = {
        "browser.startup.homepage" = "https://github.com/TheArctesian/omnixy";
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
    };
  };

  # VS Code
  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      # Themes
      pkief.material-icon-theme
      zhuangtongfa.material-theme

      # Language support
      rust-lang.rust-analyzer
      golang.go
      ms-python.python
      ms-vscode.cpptools

      # Web development
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      bradlc.vscode-tailwindcss

      # Utilities
      eamodio.gitlens
      vscodevim.vim
      yzhang.markdown-all-in-one

      # Nix
      jnoortheen.nix-ide
    ];

    userSettings = {
      "workbench.colorTheme" = lib.mkDefault "One Dark Pro";
      "workbench.iconTheme" = "material-icon-theme";
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "editor.rulers" = [ 80 120 ];
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      "vim.enableNeovim" = true;
    };
  };

  # Direnv for development environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  # Zoxide for smart cd
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout reverse"
      "--border"
      "--inline-info"
      "--color 'fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'"
    ];
  };

  # btop
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = false;
      update_ms = 1000;
    };
  };

  # GPG
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Gtk theme
  gtk = {
    enable = true;
    theme = {
      name = lib.mkDefault "Catppuccin-Mocha-Standard-Blue-dark";
      package = lib.mkDefault (pkgs.catppuccin-gtk.override {
        variant = "mocha";
      });
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Qt theme
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "gtk2";
  };
}
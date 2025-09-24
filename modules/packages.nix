{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omnixy;
in
{
  options.omnixy.packages = {
    enable = mkEnableOption "OmniXY packages";

    categories = {
      base = mkEnableOption "Base system packages" // { default = true; };
      development = mkEnableOption "Development packages" // { default = true; };
      multimedia = mkEnableOption "Multimedia packages" // { default = true; };
      productivity = mkEnableOption "Productivity packages" // { default = true; };
      gaming = mkEnableOption "Gaming packages" // { default = false; };
    };
  };

  config = mkIf (cfg.enable or true) {
    environment.systemPackages = with pkgs;
      # Base system packages (always installed)
      [
        # Core utilities
        coreutils
        util-linux
        binutils
        pciutils
        usbutils
        lshw

        # File management
        file
        tree
        ncdu
        duf
        dust

        # Networking
        iproute2
        iputils
        dnsutils
        nettools
        nmap
        wget
        curl
        aria2

        # Archives
        zip
        unzip
        p7zip
        rar
        unrar
        xz

        # System monitoring
        btop
        htop
        iotop
        iftop
        nethogs
        lsof
        sysstat

        # Text processing
        vim
        nano
        sed
        gawk
        jq
        yq-go
        ripgrep
        fd
        bat
        eza
        fzf
        zoxide

        # Version control
        git
        git-lfs
        lazygit
        gh

        # Terminal multiplexers
        tmux
        screen

        # System tools
        rsync
        rclone
        age
        sops
        gnupg
        pass
        pwgen

        # Shell and prompts
        bash
        zsh
        fish
        starship
        oh-my-posh

        # Package management helpers
        nix-index
        nix-tree
        nix-diff
        nixpkgs-fmt
        nil
        statix
        deadnix
        cachix
        lorri
        direnv
      ]

      # Development packages
      ++ optionals cfg.packages.categories.development [
        # Editors and IDEs
        neovim
        emacs
        vscode
        jetbrains.idea-community

        # Language servers
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        rust-analyzer
        gopls
        pyright
        lua-language-server
        clang-tools

        # Debuggers
        gdb
        lldb
        delve

        # Build tools
        gnumake
        cmake
        meson
        ninja
        autoconf
        automake
        libtool
        pkg-config

        # Compilers and interpreters
        gcc
        clang
        rustc
        cargo
        go
        python3
        nodejs_20
        deno
        bun

        # Container tools
        docker
        docker-compose
        podman
        buildah
        skopeo
        kind
        kubectl
        kubernetes-helm
        k9s

        # Database clients
        postgresql
        mysql80
        sqlite
        redis
        mongodb-tools
        dbeaver

        # API testing
        httpie
        curl
        postman
        insomnia

        # Cloud tools
        awscli2
        google-cloud-sdk
        azure-cli
        terraform
        ansible

        # Documentation
        mdbook
        hugo
        zola
      ]

      # Multimedia packages
      ++ optionals cfg.packages.categories.multimedia [
        # Audio
        pipewire
        pulseaudio
        pavucontrol
        easyeffects
        spotify
        spotifyd
        spotify-tui
        cmus
        mpd
        ncmpcpp

        # Video
        mpv
        vlc
        obs-studio
        kdenlive
        handbrake
        ffmpeg-full

        # Images
        imv
        feh
        gimp
        inkscape
        krita
        imagemagick
        graphicsmagick

        # Screen capture
        grim
        slurp
        wf-recorder
        flameshot
        peek

        # PDF
        zathura
        evince
        okular
        mupdf
      ]

      # Productivity packages
      ++ optionals cfg.packages.categories.productivity [
        # Browsers
        firefox
        chromium
        brave
        qutebrowser

        # Communication
        discord
        slack
        telegram-desktop
        signal-desktop
        element-desktop
        zoom-us
        teams

        # Office
        libreoffice
        onlyoffice-bin
        wpsoffice

        # Note taking
        obsidian
        logseq
        joplin-desktop
        zettlr

        # Email
        thunderbird
        aerc
        neomutt

        # Calendar
        calcurse
        khal

        # Password managers
        bitwarden
        keepassxc
        pass

        # Sync and backup
        syncthing
        nextcloud-client
        rclone
        restic
        borgbackup
      ]

      # Gaming packages
      ++ optionals cfg.packages.categories.gaming [
        steam
        lutris
        wine
        winetricks
        proton-ge-bin
        mangohud
        gamemode
        discord
        obs-studio
      ];

    # Font packages
    fonts.packages = with pkgs; [
      # Nerd fonts (for icons in terminal)
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
          "Hack"
          "Iosevka"
          "Meslo"
          "SourceCodePro"
          "UbuntuMono"
          "DroidSansMono"
          "RobotoMono"
          "Inconsolata"
        ];
      })

      # System fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      ubuntu_font_family
      roboto
      open-sans
      lato

      # Programming fonts
      jetbrains-mono
      fira-code
      hasklig
      victor-mono

      # Icon fonts
      font-awesome
      material-icons
      material-design-icons
    ];

    # Enable font configuration
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
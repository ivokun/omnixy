{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omnixy;
in
{
  # User account configuration
  users.users.${cfg.user} = {
    isNormalUser = true;
    description = "OmniXY User";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
      "libvirtd"
      "input"
      "dialout"
    ];
    shell = pkgs.bash;

    # Set initial password (should be changed on first login)
    initialPassword = "omnixy";

    # SSH keys (add your SSH public keys here)
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3... user@example.com"
    ];
  };

  # Additional user-related configurations
  users = {
    # Allow users in wheel group to use sudo
    mutableUsers = true;

    # Default shell
    defaultUserShell = pkgs.bash;
  };

  # Security settings for users
  security.pam.services = {
    # Enable fingerprint authentication
    login.fprintAuth = false;
    sudo.fprintAuth = false;

    # Enable U2F authentication (for YubiKey etc.)
    login.u2fAuth = false;
    sudo.u2fAuth = false;
  };

  # Home directory encryption (optional)
  # security.pam.enableEcryptfs = true;

  # Automatic login (disable for production)
  services.displayManager.autoLogin = {
    enable = false;
    user = cfg.user;
  };

  # User environment
  environment.systemPackages = with pkgs; [
    # User management tools
    shadow # provides passwd, useradd, etc.

    # Session management
    systemd # provides loginctl

    # User info
    finger_bsd
    idutils
  ];

  # User-specific services
  systemd.user.services = {
    # Example: Syncthing for the user
    # syncthing = {
    #   description = "Syncthing for ${cfg.user}";
    #   wantedBy = [ "default.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --no-restart --logflags=0";
    #     Restart = "on-failure";
    #     RestartSec = 10;
    #   };
    # };
  };

  # Shell initialization for all users
  programs.bash.interactiveShellInit = ''
    # User-specific aliases
    alias profile='nvim ~/.bashrc'
    alias reload='source ~/.bashrc'

    # Safety aliases
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'

    # Directory shortcuts
    alias home='cd ~'
    alias downloads='cd ~/Downloads'
    alias documents='cd ~/Documents'
    alias projects='cd ~/Projects'

    # Create standard directories if they don't exist
    mkdir -p ~/Downloads ~/Documents ~/Projects ~/Pictures ~/Videos ~/Music
  '';

  # XDG Base Directory specification
  environment.variables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # User quotas (optional)
  # fileSystems."/home".options = [ "usrquota" ];
}
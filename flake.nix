{
  description = "OmniXY - NixOS configuration for modern development";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Nix colors for automatic color scheme generation
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    # Stylix for theming
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim nightly
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR for additional packages
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          inputs.nur.overlays.default
          inputs.neovim-nightly-overlay.overlays.default
        ];
      };
    in
    {
      # NixOS configuration
      nixosConfigurations = {
        omnixy = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users = {
                  # Replace with your username
                  user = import ./home.nix;
                };
                sharedModules = [
                  inputs.nix-colors.homeManagerModules.default
                ];
              };
            }
          ];
        };

        # ISO configuration for live USB/DVD
        omnixy-iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./iso.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users = {
                  nixos = { config, pkgs, lib, inputs, ... }: {
                    imports = [ ./home.nix ];
                    
                    # Override the username and home directory for ISO
                    home.username = lib.mkForce "nixos";
                    home.homeDirectory = lib.mkForce "/home/nixos";
                  };
                };
                sharedModules = [
                  inputs.nix-colors.homeManagerModules.default
                ];
              };
            }
          ];
        };
      };

      # Development shells
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Development tools
            git
            # neovim (configured via home-manager)
            ripgrep
            fd
            bat
            eza
            fzf
            zoxide
            starship
            lazygit
            gh

            # Language servers and formatters
            nil # Nix LSP
            nixpkgs-fmt
            statix
            deadnix

            # Build tools
            gnumake
            gcc
            nodejs
            python3
            rustc
            cargo
            go
          ];

          shellHook = ''
            echo "🚀 Welcome to OmniXY development environment!"
            echo ""
            echo "Available commands:"
            echo "  omnixy-rebuild  - Rebuild system configuration"
            echo "  omnixy-update   - Update flake inputs"
            echo "  omnixy-clean    - Garbage collect nix store"
            echo ""

            # Setup aliases
            alias omnixy-rebuild="sudo nixos-rebuild switch --flake .#omnixy"
            alias omnixy-update="nix flake update"
            alias omnixy-clean="nix-collect-garbage -d"

            # Initialize starship prompt
            eval "$(starship init bash)"
          '';
        };

        # Python development
        python = pkgs.mkShell {
          packages = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.virtualenv
            python3Packages.ipython
            python3Packages.black
            python3Packages.pylint
            python3Packages.pytest
            ruff
          ];
        };

        # Node.js development
        node = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            nodePackages.npm
            nodePackages.pnpm
            nodePackages.yarn
            nodePackages.typescript
            nodePackages.eslint
            nodePackages.prettier
          ];
        };

        # Rust development
        rust = pkgs.mkShell {
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            rust-analyzer
            clippy
          ];
        };
      };

      # Packages that can be built
      packages.${system} = {
        # OmniXY scripts as packages
        omnixy-scripts = pkgs.callPackage ./packages/scripts.nix {};

        # Plymouth theme package
        plymouth-theme-omnixy = pkgs.callPackage ./packages/plymouth-theme.nix {};

        # ISO image
        iso = self.nixosConfigurations.omnixy-iso.config.system.build.isoImage;

        # Default package points to ISO
        default = self.packages.${system}.iso;
      };

      # Apps that can be run
      apps.${system} = {
        # Installer
        installer = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "omnixy-install" ''
            #!/usr/bin/env bash
            set -e

            echo "🚀 OmniXY NixOS Installer"
            echo "========================"
            echo ""

            # Check if running on NixOS
            if [ ! -f /etc/nixos/configuration.nix ]; then
              echo "Error: This installer must be run on a NixOS system"
              exit 1
            fi

            echo "This will install OmniXY configuration to your NixOS system."
            read -p "Continue? (y/n) " -n 1 -r
            echo

            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
              exit 1
            fi

            # Backup existing configuration
            echo "📦 Backing up existing configuration..."
            sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d-%H%M%S)

            # Copy new configuration
            echo "📝 Installing OmniXY configuration..."
            sudo cp -r ${self}/* /etc/nixos/

            # Initialize flake
            echo "🔧 Initializing flake..."
            cd /etc/nixos
            sudo git init
            sudo git add -A

            # Rebuild
            echo "🏗️  Rebuilding system..."
            sudo nixos-rebuild switch --flake /etc/nixos#omnixy

            echo ""
            echo "✅ Installation complete!"
            echo "🎉 Welcome to OmniXY!"
          ''}/bin/omnixy-install";
        };

        # ISO builder
        build-iso = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "omnixy-build-iso" ''
            #!/usr/bin/env bash
            set -e

            echo "🏗️ Building OmniXY ISO Image"
            echo "============================"
            echo ""

            echo "📦 Building ISO image..."
            echo "   This may take a while depending on your system..."
            echo ""

            # Build the ISO
            nix build .#iso

            # Check if build was successful
            if [ -L "./result" ]; then
              iso_path=$(readlink -f ./result)
              iso_file=$(find "$iso_path" -name "*.iso" | head -1)
              
              if [ -n "$iso_file" ]; then
                iso_size=$(du -h "$iso_file" | cut -f1)
                echo ""
                echo "✅ ISO build complete!"
                echo "📁 Location: $iso_file"
                echo "📏 Size: $iso_size"
                echo ""
                echo "🚀 You can now:"
                echo "   • Flash to USB: dd if='$iso_file' of=/dev/sdX bs=4M status=progress"
                echo "   • Burn to DVD: Use your favorite burning software"
                echo "   • Test in VM: qemu-system-x86_64 -cdrom '$iso_file' -m 4G -enable-kvm"
                echo ""
              else
                echo "❌ ISO file not found in build result"
                exit 1
              fi
            else
              echo "❌ Build failed - result symlink not found"
              exit 1
            fi
          ''}/bin/omnixy-build-iso";
        };
      };
    };
}
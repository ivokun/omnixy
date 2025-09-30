{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.omnixy;
  omnixy = import ./helpers.nix { inherit config pkgs lib; };
in
{
  config = omnixy.withFeature "coding" {
    # Development tools
    environment.systemPackages = with pkgs; [
      # Version control
      git
      git-lfs
      lazygit
      gh
      gitlab
      hub

      # Editors and IDEs
      # neovim (configured via home-manager programs.neovim)
      vscode
      vim
      emacs

      # Language servers and tools
      # Nix
      nil
      nixpkgs-fmt
      statix
      deadnix
      nixd
      alejandra

      # Rust
      rustc
      cargo
      rustfmt
      rust-analyzer
      clippy
      cargo-watch
      cargo-edit
      cargo-audit
      bacon

      # Go
      go
      gopls
      gotools
      go-tools
      golangci-lint
      delve
      gomodifytags
      gotests
      impl

      # Python
      python3
      python3Packages.pip
      python3Packages.virtualenv
      python3Packages.black
      python3Packages.pylint
      python3Packages.pytest
      python3Packages.ipython
      pyright
      ruff

      # Node.js
      nodejs
      nodePackages.npm
      nodePackages.pnpm
      nodePackages.yarn
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.eslint
      nodePackages.prettier
      nodePackages.nodemon
      deno
      bun

      # C/C++
      gcc
      clang
      cmake
      gnumake
      gdb
      lldb
      clang-tools
      ccls
      bear
      valgrind

      # Java
      jdk
      maven
      gradle
      jdt-language-server

      # Database tools
      postgresql
      mysql80
      sqlite
      redis
      mongodb
      dbeaver-bin

      # Container tools
      docker
      docker-compose
      podman
      buildah
      skopeo
      dive
      lazydocker

      # Kubernetes tools
      kubectl
      kubernetes-helm
      k9s
      kind
      minikube
      kustomize
      kubectx
      stern
      kubecolor

      # Cloud tools
      awscli2
      google-cloud-sdk
      azure-cli
      terraform
      terragrunt
      ansible
      vagrant
      packer

      # API development
      httpie
      curl
      postman
      insomnia
      grpcurl
      evans

      # Build tools
      bazel
      meson
      ninja
      scons

      # Documentation tools
      mdbook
      hugo
      mkdocs
      sphinx

      # Performance tools
      hyperfine
      flamegraph
      perf-tools
      heaptrack

      # Network tools
      wireshark
      tcpdump
      nmap
      netcat
      socat
      mtr

      # Misc development utilities
      jq
      yq-go
      fx
      direnv
      watchexec
      entr
      tmux
      tmuxinator
      asciinema
      tokei
      cloc
      tree-sitter

      # Custom development scripts
      (writeShellScriptBin "dev-postgres" ''
        #!/usr/bin/env bash
        echo "Starting PostgreSQL development container..."
        docker run --rm -d \
          --name dev-postgres \
          -e POSTGRES_PASSWORD=postgres \
          -p 5432:5432 \
          postgres:15-alpine
        echo "PostgreSQL running on localhost:5432"
        echo "Username: postgres, Password: postgres"
        echo "Stop with: docker stop dev-postgres"
      '')

      (writeShellScriptBin "dev-redis" ''
        #!/usr/bin/env bash
        echo "Starting Redis development container..."
        docker run --rm -d \
          --name dev-redis \
          -p 6379:6379 \
          redis:alpine
        echo "Redis running on localhost:6379"
        echo "Stop with: docker stop dev-redis"
      '')

      (writeShellScriptBin "dev-mysql" ''
        #!/usr/bin/env bash
        echo "Starting MySQL development container..."
        docker run --rm -d \
          --name dev-mysql \
          -e MYSQL_ROOT_PASSWORD=mysql \
          -p 3306:3306 \
          mysql:8
        echo "MySQL running on localhost:3306"
        echo "Username: root, Password: mysql"
        echo "Stop with: docker stop dev-mysql"
      '')

      (writeShellScriptBin "dev-mongodb" ''
        #!/usr/bin/env bash
        echo "Starting MongoDB development container..."
        docker run --rm -d \
          --name dev-mongodb \
          -p 27017:27017 \
          mongo:latest
        echo "MongoDB running on localhost:27017"
        echo "Stop with: docker stop dev-mongodb"
      '')

      (writeShellScriptBin "dev-env" ''
        #!/usr/bin/env bash
        # Create a development shell for a specific language

        case "$1" in
          rust)
            nix-shell -p rustc cargo rustfmt rust-analyzer clippy
            ;;
          go)
            nix-shell -p go gopls gotools
            ;;
          python)
            nix-shell -p python3 python3Packages.pip python3Packages.virtualenv
            ;;
          node)
            nix-shell -p nodejs nodePackages.npm nodePackages.pnpm
            ;;
          c|cpp)
            nix-shell -p gcc cmake gnumake gdb
            ;;
          *)
            echo "Usage: dev-env <language>"
            echo "Supported languages: rust, go, python, node, c, cpp"
            exit 1
            ;;
        esac
      '')

      (writeShellScriptBin "dev-project" ''
        #!/usr/bin/env bash
        # Initialize a new development project

        PROJECT_NAME="$1"
        PROJECT_TYPE="$2"

        if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_TYPE" ]; then
          echo "Usage: dev-project <name> <type>"
          echo "Types: rust, go, python, node, nix"
          exit 1
        fi

        mkdir -p "$PROJECT_NAME"
        cd "$PROJECT_NAME"

        case "$PROJECT_TYPE" in
          rust)
            cargo init
            echo "use flake" > .envrc
            cat > flake.nix << 'EOF'
        {
          description = "Rust development environment";
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { self, nixpkgs }:
            let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [ rustc cargo rustfmt rust-analyzer clippy ];
              };
            };
        }
        EOF
            ;;

          go)
            go mod init "$PROJECT_NAME"
            echo "use flake" > .envrc
            cat > flake.nix << 'EOF'
        {
          description = "Go development environment";
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { self, nixpkgs }:
            let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [ go gopls gotools ];
              };
            };
        }
        EOF
            ;;

          python)
            echo "use flake" > .envrc
            cat > flake.nix << 'EOF'
        {
          description = "Python development environment";
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { self, nixpkgs }:
            let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [
                  python3 python3Packages.pip python3Packages.virtualenv
                ];
                shellHook = "python -m venv .venv && source .venv/bin/activate";
              };
            };
        }
        EOF
            ;;

          node)
            npm init -y
            echo "use flake" > .envrc
            cat > flake.nix << 'EOF'
        {
          description = "Node.js development environment";
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { self, nixpkgs }:
            let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [ nodejs nodePackages.pnpm ];
              };
            };
        }
        EOF
            ;;

          nix)
            echo "use flake" > .envrc
            cat > flake.nix << 'EOF'
        {
          description = "Nix development environment";
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { self, nixpkgs }:
            let pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              packages.x86_64-linux.default = pkgs.hello;
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [ nixpkgs-fmt nil ];
              };
            };
        }
        EOF
            ;;

          *)
            echo "Unknown project type: $PROJECT_TYPE"
            exit 1
            ;;
        esac

        git init
        direnv allow

        echo "Project '$PROJECT_NAME' created with $PROJECT_TYPE template"
        echo "Run 'direnv allow' to activate the development environment"
      '')
    ];

    # Docker daemon (only if containers feature is enabled)
    virtualisation.docker = mkIf (omnixy.isEnabled "containers") {
      enable = true;
      enableOnBoot = true;
      daemon.settings = {
        features = { buildkit = true; };
        registry-mirrors = [ "https://mirror.gcr.io" ];
      };

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    # Podman as Docker alternative (disabled dockerCompat to avoid conflict)
    virtualisation.podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Development services
    services = {
      # PostgreSQL
      postgresql = {
        enable = false; # Set to true to enable
        package = pkgs.postgresql_15;
        dataDir = "/var/lib/postgresql/15";
        authentication = ''
          local all all trust
          host all all 127.0.0.1/32 trust
          host all all ::1/128 trust
        '';
      };

      # Redis
      redis.servers."" = {
        enable = false; # Set to true to enable
        port = 6379;
        bind = "127.0.0.1";
      };

      # MySQL/MariaDB
      mysql = {
        enable = false; # Set to true to enable
        package = pkgs.mariadb;
        settings = {
          mysqld = {
            bind-address = "127.0.0.1";
            port = 3306;
          };
        };
      };
    };

    # VSCode settings
    environment.variables = {
      # Enable VSCode to use Wayland
      NIXOS_OZONE_WL = "1";
    };

    # Development shell environments
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Git configuration
    programs.git = {
      enable = true;
      lfs.enable = true;
      config = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        pull.rebase = false;
        push.autoSetupRemote = true;
      };
    };

    # Enable lorri for automatic nix-shell
    services.lorri.enable = true;

  };
}
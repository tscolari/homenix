{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];

  # On Linux, wraps with nixGL when available (for non-NixOS GL support).
  # On Darwin, always a no-op — native GL works without wrapping.
  nixGLWrapIfReq =
    pkg: if pkgs.stdenv.isLinux && config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

  # Drops packages nixpkgs doesn't ship for the current platform (mostly
  # binary-only clients - e.g. Spotify/Slack ship for x86_64-linux and
  # darwin, nothing for aarch64-linux) instead of throwing when the list
  # below is realized.
  onThisPlatform = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform);

in

{
  options.programs.homenix.packages = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.homenix.enableAllByDefault;
      description = "Enable Additional Packages";
    };

    skipFirefox = mkEnableOption "skips installatio of firefox";
  };

  imports = [
    ./_linux.nix
    ./_darwin.nix
    ./btop.nix
    ./docker.nix
    ./go.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./lazysql.nix
    ./oh-my-pi.nix
    ./pi-coding-agent.nix
    ./rust.nix
  ];

  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs = {
      gh.enable = true;
      zsh.enable = true;
      k9s.enable = true;
    };

    home.packages =
      onThisPlatform (
        with pkgs;
        [
          # Cross-platform CLI tools — add new ones here
          awscli2
          azure-cli
          bat
          bats
          buf
          unstable.buildkite-cli
          calcure
          cargo
          cilium-cli
          claude-code
          unstable.codex
          cloudflared
          concurrently
          curl
          delve
          devenv
          dig
          docker
          dust
          eza
          fasd
          fd
          fly
          gcc
          gcloud
          git-crypt
          gnumake
          gnupg
          unstable.go
          go-migrate
          go-mockery
          gci
          unstable.gofumpt
          unstable.golangci-lint
          (lib.lowPrio golines)
          gomodifytags
          gonzo
          unstable.gopls
          gotests
          gotestsum
          (lib.lowPrio unstable.gotools)
          govulncheck
          patch
          grpcurl
          gum
          helmfile
          htop
          hub
          hugo
          jq
          jwt-cli
          khal
          kind
          kubectl
          kubectx
          kubernetes
          kubernetes-helm
          kubernetes-helmPlugins.helm-unittest
          lazyjournal
          libfido2
          llvm
          lsof
          lua
          luarocks
          mariadb.client
          mise
          mkcert
          mockgen
          ngrok
          nil
          nixd
          nix-index
          nodejs
          # From upstream's flake via homenix.overlays.default, not nixpkgs.
          (lib.hiPrio unstable.opencode)
          unstable.opencode-claude-auth
          mermaid-cli
          pgcli
          pkg-config
          pnpm
          postgresql
          pre-commit
          protobuf
          protoc-gen-go
          protoc-gen-go-grpc
          proton-vpn
          pulumi
          pulumiPackages.pulumi-go
          ripgrep
          rust-analyzer
          rustc
          (lib.hiPrio rustup)
          shellcheck
          socat
          softhsm
          ssh-copy-id
          teleport
          terraform
          tig
          tldr
          tmux
          tree
          tree-sitter
          universal-ctags
          unzip
          watch
          wget
          xmlstarlet
          yarn
          yq
          zellij
          zoxide
        ]
      )
      ++ map nixGLWrapIfReq (
        onThisPlatform (
          with pkgs;
          [
            # Cross-platform GUI — add new ones here
            spotify
            unstable._1password-gui
            master.obsidian
            unstable.slack
            unstable.synology-drive-client
            unstable.typora
          ]
        )
      )
      ++ lib.optional (!cfg.skipFirefox) (nixGLWrapIfReq pkgs.firefox);
  };
}

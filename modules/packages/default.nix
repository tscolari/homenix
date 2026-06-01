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
    ./go.nix
    ./lazydocker.nix
    ./lazygit.nix
    ./lazysql.nix
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

    home.packages = with pkgs; [
      # Cross-platform CLI tools — add new ones here
      awscli2
      azure-cli
      bat
      buf
      unstable.buildkite-cli
      calcure
      cargo
      cilium-cli
      claude-code
      cloudflared
      concurrently
      curl
      delve
      devenv
      dig
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
      grpcurl
      gum
      helmfile
      htop
      hub
      jq
      jwt-cli
      khal
      kind
      kubectl
      kubectx
      kubernetes
      lazyjournal
      lsof
      lua
      luarocks
      mariadb.client
      mise
      mockgen
      ngrok
      nil
      nix-index
      nodejs
      master.opencode
      master.opencode-claude-auth
      pgcli
      postgresql
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      pulumi
      pulumiPackages.pulumi-go
      redpanda-client
      ripgrep
      rustc
      shellcheck
      silver-searcher
      socat
      ssh-copy-id
      teleport
      terraform
      tig
      tldr
      tmate
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

      # Cross-platform GUI — add new ones here using nixGLWrapIfReq
      (nixGLWrapIfReq unstable._1password-gui)
      (nixGLWrapIfReq unstable.obsidian)
      (nixGLWrapIfReq unstable.slack)
      (nixGLWrapIfReq unstable.typora)
      (nixGLWrapIfReq unstable.opencode-desktop)
      (nixGLWrapIfReq gimp)

      # Fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      ia-writer-duospace
      nerd-fonts.caskaydia-mono
    ];
  };
}

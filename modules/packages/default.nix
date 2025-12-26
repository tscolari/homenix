{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.packages;

  isNixOS = config.programs.homenix.isNixOS;

  nixGLWrapIfReq = pkg: if config.lib ? nixGL then config.lib.nixGL.wrap pkg else pkg;

  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];

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
    ./btop.nix
    ./go.nix
    ./rust.nix
  ];

  config = mkIf (cfg.enable && config.programs.homenix.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

    home.packages =
      with pkgs;
      [
        (lib.hiPrio ruby)
        awscli2
        azure-cli
        bat
        btop
        buf
        calcure
        calibre
        cargo
        cilium-cli
        cloudflared
        concurrently
        curl
        delve
        devenv
        dig
        distrobox
        docker-compose
        dust
        eza
        fasd
        fd
        fly
        gcloud
        gh
        git-crypt
        gnupg
        go
        go-migrate
        go-mockery
        gofumpt
        golangci-lint
        golines
        gomodifytags
        gonzo
        gopls
        gotests
        gotestsum
        gotools
        govulncheck
        grpcurl
        gtop
        helmfile
        htop
        hub
        inxi
        jq
        jwt-cli
        khal
        killall
        kind
        k9s
        kubectl
        kubectx
        kubernetes
        lazydocker
        lazyjournal
        libsecret
        lsof
        lua
        luarocks
        lyrebird
        mariadb.client
        claude-code
        mise
        mockgen
        mutter
        nil
        nix-index
        nodejs
        p11-kit
        pamixer
        pciutils
        pgcli
        playerctl
        pmutils
        podman
        postgresql
        procps
        protobuf
        protoc-gen-go
        protoc-gen-go-grpc
        pstree
        pulumi
        pulumiPackages.pulumi-go
        redpanda-client
        ripgrep
        rustc
        shellcheck
        silver-searcher
        slurp
        socat
        ssh-copy-id
        sysprof
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
        wl-clipboard
        xmlstarlet
        yarn
        yq
        zoxide
        zsh

        # UI
        (nixGLWrapIfReq _1password-gui)
        (nixGLWrapIfReq cameractrls-gtk4)
        (nixGLWrapIfReq evince)
        (nixGLWrapIfReq obsidian)
        (nixGLWrapIfReq satty)
        (nixGLWrapIfReq slack)
        (nixGLWrapIfReq spotify)
        (nixGLWrapIfReq typora)
        yaru-theme

        # System libraries and frameworks
        # gnome-keyring # Credential storage service

        # Qt system libraries
        kdePackages.qtwayland
        libsForQt5.qtstyleplugin-kvantum

        # System themes
        # gnome-themes-extra

        # Fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        ia-writer-duospace
        nerd-fonts.caskaydia-mono
      ]
      ++ lib.optional (!cfg.skipFirefox) (nixGLWrapIfReq firefox)
      ++ lib.optionals (isNixOS) [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        gnome-keyring
      ];

    # # Rust / cargo:
    # * bluetui
  };
}

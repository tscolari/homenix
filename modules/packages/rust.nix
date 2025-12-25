{
  config,
  pkgs,
  lib,
  ...
}:

# GO packages to be installed

let

  cfg = config.programs.homenix.packages;

  bluetui = pkgs.rustPlatform.buildRustPackage rec {
    pname = "bluetui";
    version = "v0.8.0";

    src = pkgs.fetchFromGitHub {
      owner = "pythops";
      repo = pname;
      rev = version;
      hash = "sha256-8X1kr0GPY/DqGZb1hJ52OkmgtYk0giwTeoqWTN0ZEbI=";
    };

    cargoHash = "sha256-CQFjauJ/y7XWZob/8gRQszKjBbkSdIt5l5OlSKVKoMw=";

    nativeBuildInputs = [ pkgs.pkg-config ];

    buildInputs = [ pkgs.dbus ];

    meta = with lib; {
      description = "TUI for managing bluetooth on Linux ";
      homepage = "https://github.com/pythops/bluetui";
      license = licenses.gpl3Only;
      maintainers = [ ];
    };
  };

in
{
  config = lib.mkIf (cfg.enable && config.programs.homenix.enable) {
    home.packages = [
      bluetui
    ];
  };
}

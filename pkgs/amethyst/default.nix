# Amethyst — an xmonad-inspired automatic tiling window manager for macOS.
#
# Not in nixpkgs, so this vendors the notarized release build. The bundle is a
# universal (x86_64 + arm64) binary signed with the author's Developer ID.
{
  lib,
  fetchurl,
  libarchive,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "amethyst";
  version = "0.25.0";

  src = fetchurl {
    url = "https://github.com/ianyh/Amethyst/releases/download/v${finalAttrs.version}/Amethyst.zip";
    hash = "sha256-y9yrOMFOWxyzWVN/rw8nS313rrLTz+8ZgoZuIISIBDc=";
  };

  # The zip is an .app bundle whose embedded Sparkle.framework is built from
  # symlinks. Unpacking with `unzip` in the usual unpackPhase mangles them and
  # invalidates the code signature, which Amethyst needs intact to keep its
  # Accessibility grant. bsdtar preserves them, so extract by hand instead.
  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [ libarchive ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    bsdtar -xf $src -C $out/Applications/

    mkdir -p $out/bin
    ln -s $out/Applications/Amethyst.app/Contents/MacOS/Amethyst $out/bin/Amethyst

    runHook postInstall
  '';

  # The default fixup phase would strip the Mach-O binaries, which breaks the
  # notarized signature.
  dontFixup = true;

  meta = {
    description = "Automatic tiling window manager for macOS, inspired by xmonad";
    longDescription = ''
      Amethyst is a developer-signed and notarized tiling window manager for
      macOS. It arranges windows into configurable layouts automatically and is
      configured through ~/.amethyst.yml or its preferences window.

      Requires macOS 12+ and the Accessibility permission granted on first
      launch. Its bundled Sparkle self-updater cannot replace a bundle in the
      read-only Nix store; bump the version here instead.
    '';
    homepage = "https://github.com/ianyh/Amethyst";
    changelog = "https://github.com/ianyh/Amethyst/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "Amethyst";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

# OmniWM — a Niri/Hyprland-inspired tiling window manager for macOS.
#
# Upstream ships no Nix support, so this vendors the notarized release build.
# See OMNI-WM-PROJECT.md for the wider context.
{
  lib,
  fetchurl,
  libarchive,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omniwm";
  version = "0.6.3";

  src = fetchurl {
    url = "https://github.com/BarutSRB/OmniWM/releases/download/v${finalAttrs.version}/OmniWM-v${finalAttrs.version}.zip";
    hash = "sha256-rDRDQYOUxvntH5mA1EoXa6LPeqV2zN3OpnaD+eHOLiU=";
  };

  # The zip is an .app bundle, not a source tree. Unpacking it with `unzip` in the
  # usual unpackPhase mangles the bundle's internal symlinks, which invalidates the
  # code signature — and OmniWM needs an intact signature to hold onto its
  # Accessibility / Input Monitoring grants. bsdtar preserves them, so extract by
  # hand in installPhase instead.
  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [ libarchive ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    bsdtar -xf $src -C $out/Applications/

    mkdir -p $out/bin
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/OmniWM $out/bin/OmniWM
    ln -s $out/Applications/OmniWM.app/Contents/MacOS/omniwmctl $out/bin/omniwmctl

    runHook postInstall
  '';

  # Nothing to fix up in a prebuilt, signed bundle — and the default fixup phase
  # would strip the Mach-O binaries, which breaks the notarized signature.
  dontFixup = true;

  meta = {
    description = "Niri- and Hyprland-inspired tiling window manager for macOS";
    longDescription = ''
      OmniWM is a developer-signed and notarized macOS tiling window manager. It
      offers Niri-style scrolling columns alongside Hyprland-style dwindle
      layouts, plus a quake terminal, command palette, overview mode and an
      IPC/CLI (omniwmctl) for automation.

      Requires macOS 26+ on Apple Silicon, and Accessibility plus Input
      Monitoring permissions granted on first launch.
    '';
    homepage = "https://github.com/BarutSRB/OmniWM";
    license = lib.licenses.gpl2Only;
    # The CLI, not the app: the app is launched by full path from a launchd
    # agent, while omniwmctl is what other code reaches for via getExe.
    mainProgram = "omniwmctl";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

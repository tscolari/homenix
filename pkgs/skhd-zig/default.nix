# skhd.zig — a maintained Zig port of koekeishiya/skhd.
#
# Why not pkgs.skhd: the original (0.3.9, the newest upstream tag) segfaults on
# macOS 26 the instant any bound chord is pressed — inside the event-tap path,
# before it ever forks a command. skhd.zig is config-compatible and works.
# See OMNI-WM-PROJECT.md.
#
# Upstream ships no flake or nix expression, so this vendors the release build.
{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  version = "0.2.0";

  # Prebuilt per-arch tarballs; each unpacks to a single skhd.app bundle.
  sources = {
    aarch64-darwin = {
      arch = "arm64";
      hash = "sha256-C0jY80n2tzhJ4zj+jfpdwUB39Yuu6Y4B4qp4TWchs0A=";
    };
    x86_64-darwin = {
      arch = "x86_64";
      hash = "sha256-I1ROsPIz9jckCzlJ/9SSKSkZUuoV6gD0jr0q8f/ASH8=";
    };
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "skhd-zig";
  inherit version;

  src =
    let
      source =
        sources.${stdenvNoCC.hostPlatform.system}
          or (throw "skhd-zig: no release binary for ${stdenvNoCC.hostPlatform.system}");
    in
    fetchurl {
      url = "https://github.com/jackielii/skhd.zig/releases/download/v${finalAttrs.version}/skhd-${source.arch}-macos.tar.gz";
      inherit (source) hash;
    };

  sourceRoot = "skhd.app";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/skhd.app
    cp -R . $out/Applications/skhd.app

    # skhd must keep its bundle identity (com.jackielii.skhd) to hold onto its
    # Accessibility and Input Monitoring grants, so run the executable in place
    # rather than copying it out of the bundle.
    mkdir -p $out/bin
    ln -s $out/Applications/skhd.app/Contents/MacOS/skhd $out/bin/skhd
    ln -s $out/Applications/skhd.app/Contents/MacOS/skhd-grabber $out/bin/skhd-grabber

    runHook postInstall
  '';

  # Prebuilt and already signed; the default fixup would strip the Mach-O
  # binaries and invalidate that signature.
  dontFixup = true;

  meta = {
    description = "Simple hotkey daemon for macOS, ported from skhd to Zig";
    longDescription = ''
      A maintained rewrite of koekeishiya/skhd that keeps the original skhdrc
      config format and CLI flags.

      Note the release build is self-signed rather than notarized, so Gatekeeper
      rejects launching it via Finder or `open`. Running the executable directly
      by path — which is what a launchd agent does — is unaffected.
    '';
    homepage = "https://github.com/jackielii/skhd.zig";
    license = lib.licenses.mit;
    mainProgram = "skhd";
    platforms = lib.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

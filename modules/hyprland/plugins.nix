{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let

  cfg = config.programs.homenix.hyprland;

  # Upstream Hyprspace only registers NATIVE dispatchers (overview:toggle/open/
  # close), which Hyprland's lua config cannot invoke (no hl.keyword, and
  # hl.bind/hl.dispatch only accept hl.dsp.* objects or lua functions — never a
  # plugin's string dispatcher). Patch Hyprspace to ALSO expose those actions as
  # lua plugin functions via HyprlandAPI::addLuaFunction, so the config can bind
  # `hl.plugin.overview.toggle()` (mirrors how hyprbars/hyprexpo expose lua fns).
  # Uses non-capturing lambdas (convert to PLUGIN_LUA_FN = int(*)(lua_State*));
  # lua_State is forward-declared in PluginAPI.hpp, so no extra includes needed.
  hyprspaceWithLua = pkgs.hyprlandPlugins.hyprspace.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's|\(HyprlandAPI::addDispatcherV2(pHandle, "overview:close", ::dispatchCloseOverview);\)|\1\n    HyprlandAPI::addLuaFunction(pHandle, "overview", "toggle", [](lua_State*) -> int { dispatchToggleOverview(""); return 0; });\n    HyprlandAPI::addLuaFunction(pHandle, "overview", "open", [](lua_State*) -> int { dispatchOpenOverview(""); return 0; });\n    HyprlandAPI::addLuaFunction(pHandle, "overview", "close", [](lua_State*) -> int { dispatchCloseOverview(""); return 0; });|' src/main.cpp
      grep -q 'addLuaFunction(pHandle, "overview", "toggle"' src/main.cpp \
        || (echo "homenix: Hyprspace lua-function patch failed to apply (upstream source changed)"; exit 1)
    '';
  });

in
{
  options.programs.homenix.hyprland.plugins.hyprspace = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable the Hyprspace workspace-overview plugin";
    };

    package = mkOption {
      type = types.package;
      default = hyprspaceWithLua;
      description = "Hyprspace plugin package (patched to expose hl.plugin.overview.* lua functions; must be built against the running Hyprland)";
    };
  };

  config = mkIf (config.programs.homenix.enable && cfg.enable && cfg.plugins.hyprspace.enable) {
    wayland.windowManager.hyprland.plugins = [ cfg.plugins.hyprspace.package ];
  };
}

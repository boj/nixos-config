{ config, lib, pkgs, ... }:
let cfg = config.my.steam; in {
  options.my.steam.enable = lib.mkEnableOption "Steam gaming";
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
        "steam-runtime"
        "steam-unwrapped"
        "proton-ge-bin"
      ];

    # Defensive: programs.steam normally sets this, but make it explicit so
    # 32-bit Vulkan/GL is always available regardless of module ordering.
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };

    programs.gamescope.enable = true;
    programs.gamemode.enable = true;

    # Fixes "Failed to call method ... org.freedesktop.UPower" warnings from
    # Steam's CEF that can leak into game launchers and stall startup.
    services.upower.enable = true;
  };
}

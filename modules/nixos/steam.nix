{ config, lib, ... }:
let cfg = config.my.steam; in {
  options.my.steam.enable = lib.mkEnableOption "Steam gaming";
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
        "steam-runtime"
      ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}

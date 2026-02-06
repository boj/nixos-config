{ config, lib, pkgs, ... }:
let cfg = config.my.ai; in {
  options.my.ai.enable = lib.mkEnableOption "AI/Ollama";
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "10.3.0";
    };
  };
}

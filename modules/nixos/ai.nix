{ config, lib, pkgs, ... }:
let
  cfg = config.my.ai;
  gpu = config.my.gpu;
in {
  options.my.ai.enable = lib.mkEnableOption "AI/Ollama";
  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = if gpu == "amd" then pkgs.ollama-rocm else pkgs.ollama;
    } // lib.optionalAttrs (gpu == "amd") {
      rocmOverrideGfx = "10.3.0";
    };
  };
}

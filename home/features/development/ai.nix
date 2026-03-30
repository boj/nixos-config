{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.development.ai;
  gpu = config.my.gpu;
in {
  options.my.development.ai.enable = lib.mkEnableOption "AI development tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gemini-cli
      github-copilot-cli
      claude-code
      (if gpu == "amd" then llama-cpp-rocm else llama-cpp)
      ollama
    ];
  };
}

{ config, lib, pkgs, ... }: let
  cfg = config.my.gpu;
in {
  options.my.gpu = lib.mkOption {
    type = lib.types.enum ["amd" "nvidia" "none"];
    default = "none";
    description = "GPU vendor, used to select ROCm vs CUDA package variants.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "nvidia") {
      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      hardware.graphics.enable = true;
      environment.systemPackages = [
        config.boot.kernelPackages.nvidiaPackages.stable
        pkgs.cudaPackages.cudatoolkit
      ];
    })
    (lib.mkIf (cfg == "amd") {
      hardware.graphics.enable = true;
    })
  ];
}

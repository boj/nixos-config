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
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          libva
          libvdpau
          libva-vdpau-driver
        ];
      };
      environment.systemPackages = with pkgs; [
        config.boot.kernelPackages.nvidiaPackages.stable
        cudaPackages.cudatoolkit
        # Runtime libs DaVinci Resolve uses for NVDEC/NVENC playback.
        nv-codec-headers
        libva-utils
      ];
    })
    (lib.mkIf (cfg == "amd") {
      hardware.graphics.enable = true;
    })
  ];
}

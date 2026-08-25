{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gpu;
in {
  options.my.gpu = lib.mkOption {
    type = lib.types.enum ["amd" "nvidia" "intel" "none"];
    default = "none";
    description = "GPU vendor, used to select ROCm vs CUDA vs Intel package variants.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg != "none") {
      hardware.graphics.enable = true;
      # OpenCL support (needed by DaVinci Resolve).
      # ocl-icd provides libOpenCL.so (the ICD loader) and its headers;
      # mesa.opencl provides Mesa's Rusticl/Clover ICD as a fallback.
      hardware.graphics.extraPackages = with pkgs; [
        ocl-icd
        mesa.opencl
      ];
      environment.systemPackages = with pkgs; [
        ocl-icd
        clinfo
      ];
    })
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
      # ROCm OpenCL runtime — DaVinci Resolve requires this on AMD GPUs.
      hardware.graphics.extraPackages = [pkgs.rocmPackages.clr.icd];
    })
    (lib.mkIf (cfg == "intel") {
      # Intel iGPU (i915/xe). VAAPI via intel-media-driver (iHD), oneVPL
      # runtime, and the NEO OpenCL runtime for compute workloads.
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
          intel-compute-runtime
        ];
      };
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    })
  ];
}

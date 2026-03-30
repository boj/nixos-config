{ lib, ... }: {
  options.my.gpu = lib.mkOption {
    type = lib.types.enum ["amd" "nvidia" "none"];
    default = "none";
    description = "GPU vendor, used to select ROCm vs CUDA package variants.";
  };
}

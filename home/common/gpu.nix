{ lib, ... }: {
  options.my.gpu = lib.mkOption {
    type = lib.types.enum ["amd" "nvidia" "intel" "none"];
    default = "none";
    description = "GPU vendor, used to select ROCm vs CUDA vs Intel package variants.";
  };
}

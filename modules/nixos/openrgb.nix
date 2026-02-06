{ config, lib, pkgs, ... }:
let
  cfg = config.my.openrgb;
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    done
  '';
in {
  options.my.openrgb.enable = lib.mkEnableOption "OpenRGB";
  config = lib.mkIf cfg.enable {
    services.udev.packages = [pkgs.openrgb];
    hardware.i2c.enable = true;

    systemd.services.no-rgb = {
      description = "no-rgb";
      serviceConfig = {
        ExecStart = "${no-rgb}/bin/no-rgb";
        Type = "oneshot";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}

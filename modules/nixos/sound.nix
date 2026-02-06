{ config, lib, pkgs, ... }:
let cfg = config.my.sound; in {
  options.my.sound.enable = lib.mkEnableOption "PipeWire";
  config = lib.mkIf cfg.enable {
    hardware.enableAllFirmware = true;
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pipewire
      pulseaudio
    ];
  };
}

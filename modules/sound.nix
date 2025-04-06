{pkgs, ...}: {
  hardware.enableAllFirmware = true;
  services.pulseaudio.enable = false;
  #sound.enable = false;
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
}

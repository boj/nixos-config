{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Anchorage";

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  hardware.enableAllFirmware = true;
  hardware.pulseaudio.enable = false;
  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    wget

    pipewire
    pulseaudio
  ];
}

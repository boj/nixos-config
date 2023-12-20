{pkgs, lib, ...}:

{
  programs.fish.enable = true;

  users.users.bojo = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "input"
      "sound"
      "tty"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

	nix.settings.trusted-users = [ "bojo" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  i18n.defaultLocale = "en_US.UTF-8";

	nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  time.timeZone = "America/Anchorage";

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

  environment.systemPackages = with pkgs; [
    curl
    git
    wget

    pipewire
    pulseaudio
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

}

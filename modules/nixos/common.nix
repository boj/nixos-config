{
  pkgs,
  lib,
  username,
  ...
}: {
  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  # TODO: remove once upower self-test is fixed upstream in nixpkgs
  nixpkgs.overlays = [
    (final: prev: {
      upower = prev.upower.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Anchorage";

  # Allow for quick ephemeral edits
  environment.etc.hosts.mode = "0644";

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  environment.systemPackages = with pkgs; [
    cachix
    curl
    git
    wget
  ];

  environment.localBinInPath = true;

  programs.fish.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "input"
      "libvirtd"
      "plugdev"
      "sound"
      "tty"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  nix.settings.trusted-users = [username];
}

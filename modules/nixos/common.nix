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
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://hyprland.cachix.org"
    "https://helix.cachix.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

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
    mosh
    nh
    wget
  ];

  # Allow mosh UDP traffic
  networking.firewall.allowedUDPPortRanges = [{from = 60000; to = 61000;}];

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

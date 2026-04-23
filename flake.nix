{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?rev=0002f148c9a4fe421a9d33c0faa5528cdc411e62";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprland-contrib.url = "github:hyprwm/contrib";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  }: let
    system = "x86_64-linux";
    username = "bojo";
    userFullName = "Brian Jones";
    userEmail = "bojo@bojo.wtf";
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICu6ak4iW3v0H7kRoSg/kVOnnO89fwri/6SDBIa6ir7n bojo@bruh"
    ];
    defaultWallpaper = ./hyprland.png;
    mkHost = import ./lib/mkHost.nix {inherit inputs system username userFullName userEmail sshKeys defaultWallpaper;};
  in {
    nixosConfigurations = {
      "bruh" = mkHost {name = "bruh";};
      "worky" = mkHost {name = "worky";};
      "wsl" = mkHost {
        name = "wsl";
        homeModule = ./home/wsl.nix;
        stylix = false;
        extraModules = [nixos-wsl.nixosModules.wsl];
      };
    };
  };
}

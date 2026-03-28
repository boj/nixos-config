{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland";
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
    specialArgs = {inherit inputs username;};
    defaultWallpaper = ./hyprland.png;
    stylixConfig = {pkgs, ...}: {
      stylix = {
        enable = true;
        image = ./hyprland.png;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
      };
    };
  in {
    nixosConfigurations = {
      "bruh" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/bruh
          inputs.stylix.nixosModules.stylix
          stylixConfig
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [(import ./home/bojo.nix)];
              my.wayland.hyprland.useFunctionKeys = true;
              my.wayland.hyprland.monitors = [
                "DP-1,1920x1080@240,0x0,1"
                "DP-3,1920x1080@240,1920x0,1"
              ];
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
      "worky" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/worky
          inputs.stylix.nixosModules.stylix
          stylixConfig
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [(import ./home/bojo.nix)];
              my.wayland.weather.location = "Palmer,Alaska";
              my.wayland.hyprland.monitors = [
                "DP-1,1920x1080@60,0x0,1"
                "DP-2,1920x1080@60,1920x0,1"
                "eDP-1,1920x1080@120,0x1080,1"
              ];
              my.wayland.battery.enable = true;
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
              ];
              my.wayland.hyprland.idleTimeout = 1200;
            };
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
      "wsl" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/wsl
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home/wsl.nix;
            home-manager.extraSpecialArgs = {inherit inputs username defaultWallpaper;};
          }
        ];
      };
    };
  };
}

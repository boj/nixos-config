{
  description = "bojo's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
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

    nix-colors.url = "github:misterio77/nix-colors";
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
  in {
    nixosConfigurations = {
      "bruh" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/bruh
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [(import ./home/bojo.nix)];
              my.wayland.hyprland.monitors = [
                "DP-1,1920x1080@240,0x0,1"
                "DP-3,1920x1080@240,1920x0,1"
              ];
              my.wayland.hyprland.workspaces = [
                "1,monitor:DP-1,default:true"
                "2,monitor:DP-1"
                "3,monitor:DP-1"
                "4,monitor:DP-1"
                "5,monitor:DP-1"
                "6,monitor:DP-3,default:true"
                "7,monitor:DP-3"
                "8,monitor:DP-3"
                "9,monitor:DP-3"
                "10,monitor:DP-3"
              ];
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
                "[workspace 6 silent] discord"
                "[workspace 6 silent] kitty btop"
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs username;};
          }
        ];
      };
      "worky" = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nixos
          ./hosts/worky
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = [(import ./home/bojo.nix)];
              my.wayland.hyprland.monitors = [
                "DP-1,1920x1080@60,0x0,1"
                "DP-2,1920x1080@60,1920x0,1"
                "eDP-1,1920x1080@120,0x1080,1"
              ];
              my.wayland.hyprland.workspaces = [
                "1,monitor:eDP-1,default:true"
                "2,monitor:eDP-1"
                "3,monitor:eDP-1"
                "4,monitor:eDP-1"
                "5,monitor:DP-1,default:true"
                "6,monitor:DP-1"
                "7,monitor:DP-1"
                "8,monitor:DP-2,default=true"
                "9,monitor:DP-2"
                "0,monitor:DP-2"
              ];
              my.wayland.hyprland.execOnce = [
                "[workspace 1 silent] firefox"
              ];
            };
            home-manager.extraSpecialArgs = {inherit inputs username;};
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
            home-manager.extraSpecialArgs = {inherit inputs username;};
          }
        ];
      };
    };
  };
}

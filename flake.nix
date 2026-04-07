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
    specialArgs = {inherit inputs username;};
    defaultWallpaper = ./hyprland.png;
    stylixConfig = {pkgs, ...}: {
      stylix = {
        enable = true;
        image = ./hyprland.png;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        polarity = "dark";
        targets.chromium.enable = false;
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
              my.gpu = "amd";
              my.wayland.weather.latitude = 61.32;
              my.wayland.weather.longitude = -149.39;
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
              my.gpu = "nvidia";
              my.wayland.weather.latitude = 61.60;
              my.wayland.weather.longitude = -149.11;
              my.wayland.battery.enable = true;
              my.wayland.hyprland.monitors = [
                "desc:Dell Inc. DELL P2417H KH0NG77E1VVB,1920x1080@60,0x0,1"
                "desc:Dell Inc. DELL P2417H KH0NG7873KDI,1920x1080@60,1920x0,1"
                "desc:AU Optronics 0x97A2,3840x2160@120,0x1080,2"
              ];
              my.wayland.hyprland.workspaces = [
                "1, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB, default:true"
                "2, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
                "3, monitor:desc:Dell Inc. DELL P2417H KH0NG77E1VVB"
                "4, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI, default:true"
                "5, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
                "6, monitor:desc:Dell Inc. DELL P2417H KH0NG7873KDI"
                "7, monitor:desc:AU Optronics 0x97A2, default:true"
                "8, monitor:desc:AU Optronics 0x97A2"
                "9, monitor:desc:AU Optronics 0x97A2"
              ];
              my.wayland.hyprland.waybarPersistentWorkspaces = {
                "DP-8" = [1 2 3];
                "DP-7" = [4 5 6];
                "eDP-1" = [7 8 9];
              };
              my.wayland.kanshi = {
                enable = true;
                profiles = {
                  docked = {
                    outputs = [
                      {
                        criteria = "Dell Inc. DELL P2417H KH0NG77E1VVB";
                        mode = "1920x1080@60";
                        position = "0,0";
                      }
                      {
                        criteria = "Dell Inc. DELL P2417H KH0NG7873KDI";
                        mode = "1920x1080@60";
                        position = "1920,0";
                      }
                      {
                        criteria = "eDP-1";
                        mode = "3840x2160@120";
                        position = "0,1080";
                      }
                    ];
                    exec = [
                      "move-workspaces 1:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 2:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 3:desc:Dell_Inc._DELL_P2417H_KH0NG77E1VVB 4:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 5:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 6:desc:Dell_Inc._DELL_P2417H_KH0NG7873KDI 7:eDP-1 8:eDP-1 9:eDP-1"
                      ''waybar-set-workspaces '{"DP-8":[1,2,3],"DP-7":[4,5,6],"eDP-1":[7,8,9]}' ''
                      "restart-waybar"
                    ];
                  };
                  undocked = {
                    outputs = [
                      {
                        criteria = "eDP-1";
                        mode = "3840x2160@60";
                        position = "0,0";
                      }
                    ];
                    exec = [
                      "move-workspaces 1:eDP-1 2:eDP-1 3:eDP-1 4:eDP-1 5:eDP-1 6:eDP-1 7:eDP-1 8:eDP-1 9:eDP-1"
                      ''waybar-set-workspaces '{"*":[1,2,3,4,5,6,7,8,9]}' ''
                      "restart-waybar"
                    ];
                  };
                };
              };
              my.wayland.hyprland.execOnce = [
                "hyprlock"
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

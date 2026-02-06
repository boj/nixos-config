{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 1;
        };
      };
    };
  };
}

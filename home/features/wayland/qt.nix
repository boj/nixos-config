{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.enable {
    stylix.targets.qt.enable = false;
    qt = {
      enable = true;
    };
  };
}

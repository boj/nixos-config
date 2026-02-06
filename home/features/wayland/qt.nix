{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.enable {
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };
  };
}

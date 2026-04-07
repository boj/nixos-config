{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.wayland.enable {};
}

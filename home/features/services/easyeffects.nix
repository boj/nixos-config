{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.easyeffects;
in {
  options.my.services.easyeffects.enable = lib.mkEnableOption "EasyEffects noise reduction";

  config = lib.mkIf cfg.enable {
    xdg.configFile."easyeffects/input/noise-reduction.json".text = builtins.toJSON {
      input = {
        blocklist = [];
        plugins_order = [
          "rnnoise#0"
        ];
        "rnnoise#0" = {
          bypass = false;
          enable-vad = true;
          input-gain = 0.0;
          model-path = "";
          output-gain = 0.0;
          release = 20.0;
          vad-thres = 30.0;
          wet = 0.0;
        };
      };
    };

    services.easyeffects = {
      enable = true;
      preset = "noise-reduction";
    };
  };
}

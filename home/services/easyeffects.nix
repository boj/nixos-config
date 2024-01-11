{
  services.easyeffects = {
    enable = true;
    preset = ''
      {
          "input": {
              "blocklist": [],
              "plugins_order": [
                  "rnnoise#0"
              ],
              "rnnoise#0": {
                  "bypass": false,
                  "enable-vad": true,
                  "input-gain": 0.0,
                  "model-path": "",
                  "output-gain": 0.0,
                  "release": 20.0,
                  "vad-thres": 30.0,
                  "wet": 0.0
              }
          }
      }
    '';
  };
}

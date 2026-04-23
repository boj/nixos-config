{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  scriptDeps = with pkgs; [bash coreutils curl imagemagick file python3];

  get-ddg-links = pkgs.writeScript "get_ddg_links.py" (builtins.readFile ./get_ddg_links.py);

  ddg-search = pkgs.writeShellScriptBin "ddg-search" ''
    export PATH="${lib.makeBinPath scriptDeps}:$PATH"

    QUERY="$1"
    CACHE_DIR="$HOME/.cache/wallpaper_picker"
    SEARCH_DIR="$CACHE_DIR/search_thumbs"
    MAP_FILE="$CACHE_DIR/search_map.txt"
    CONTROL_FILE="/tmp/ddg_search_control"
    LOG_FILE="/tmp/qs_ddg_downloader.log"

    echo "=== Starting search for: $QUERY ===" > "$LOG_FILE"

    mkdir -p "$SEARCH_DIR"

    python3 -u "${get-ddg-links}" "$QUERY" | while IFS='|' read -r thumb_url full_url; do

        state=$(cat "$CONTROL_FILE" 2>/dev/null | tr -d '[:space:]')

        if [[ "$state" == "stop" ]]; then
            echo "Stop signal received. Exiting." >> "$LOG_FILE"
            exit 0
        fi

        while [[ "$state" == "pause" ]]; do
            sleep 1
            state=$(cat "$CONTROL_FILE" 2>/dev/null | tr -d '[:space:]')
        done

        if [ -z "$thumb_url" ] || [ -z "$full_url" ]; then continue; fi

        target_headers=$(curl -s -I -L -m 3 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$full_url")
        target_type=$(echo "$target_headers" | grep -i "content-type:" | tail -n 1 | tr -d '\r')

        if [[ ! "$target_type" =~ "image/" ]]; then
            echo "Skip: Full URL is dead or HTML ($target_type) -> $full_url" >> "$LOG_FILE"
            continue
        fi

        uuid=$(date +%s%N)
        ext="''${full_url##*.}"
        ext="''${ext%%\?*}"
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        if [[ ! "$ext" =~ ^(jpg|jpeg|png|webp|gif)$ ]]; then ext="jpg"; fi

        is_webp=0
        if [[ "$ext" == "webp" ]]; then
            is_webp=1
            ext="jpg"
        fi

        filename="ddg_''${uuid}.''${ext}"
        filepath="$SEARCH_DIR/$filename"
        tmppath="''${filepath}.tmp"

        echo "Downloading Thumb: $thumb_url -> $filename" >> "$LOG_FILE"

        curl -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$thumb_url" -o "$tmppath"

        state=$(cat "$CONTROL_FILE" 2>/dev/null | tr -d '[:space:]')
        if [[ "$state" == "stop" ]]; then
            echo "Stop signal received during download. Discarding." >> "$LOG_FILE"
            rm -f "$tmppath"
            exit 0
        fi

        if [ -s "$tmppath" ]; then
            actual_mime=$(file -b --mime-type "$tmppath")

            if [[ ! "$actual_mime" =~ ^image/ ]]; then
                echo "ERROR: Thumb is not an image ($actual_mime). Discarding." >> "$LOG_FILE"
                rm -f "$tmppath"
            else
                if [[ "$actual_mime" == "image/webp" ]] || [ $is_webp -eq 1 ]; then
                    magick "$tmppath" "$filepath" 2>/dev/null || mv "$tmppath" "$filepath"
                    rm -f "$tmppath"
                else
                    mv "$tmppath" "$filepath"
                fi
                echo "$filename|$full_url" >> "$MAP_FILE"
                echo "Success: $filename saved." >> "$LOG_FILE"
            fi
        else
            echo "ERROR: Failed or empty download for $thumb_url" >> "$LOG_FILE"
            rm -f "$tmppath"
        fi
    done

    echo "=== Pipeline finished ===" >> "$LOG_FILE"
  '';

  generate-thumbs = pkgs.writeShellScriptBin "generate-thumbs" ''
    export PATH="${lib.makeBinPath (with pkgs; [coreutils imagemagick])}:$PATH"

    SRC_DIR="$HOME/Pictures/Wallpapers"
    THUMB_DIR="$HOME/.cache/wallpaper_picker/thumbs"
    mkdir -p "$THUMB_DIR" "$SRC_DIR"

    if command -v magick &>/dev/null; then CMD="magick"; else CMD="convert"; fi

    for file in "$SRC_DIR"/*; do
        [ -f "$file" ] || continue
        name=$(basename "$file")

        case "''${name##*.}" in
            mp4|mkv|mov|webm)
                thumb="$THUMB_DIR/000_''${name%.*}.jpg"
                ;;
            *)
                thumb="$THUMB_DIR/$name"
                ;;
        esac

        [ -f "$thumb" ] && continue
        $CMD "$file" -resize x420 -quality 70 "$thumb" 2>/dev/null || true
    done
  '';

  toggle-wallpicker = pkgs.writeShellScriptBin "toggle-wallpicker" ''
    export PATH="${lib.makeBinPath (with pkgs; [hyprland jq coreutils])}:$PATH"

    MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
    MON=$(hyprctl monitors -j | jq ".[] | select(.name == \"$MONITOR\")")
    MX=$(echo "$MON" | jq -r '.x')
    MY=$(echo "$MON" | jq -r '.y')
    MW=$(echo "$MON" | jq -r '.width')
    MH=$(echo "$MON" | jq -r '.height')

    echo "toggle:$MX:$MY:$MW:$MH" > /tmp/wallpicker_state
  '';

  shell-qml = pkgs.writeText "shell.qml" ''
    import Quickshell
    import Quickshell.Io
    import Quickshell.Wayland
    import QtQuick

    ShellRoot {
        PanelWindow {
            id: mainWindow
            color: "transparent"
            visible: false
            implicitHeight: 650

            WlrLayershell.namespace: "wallpaper-picker"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                left: true
                right: true
            }

            WallpaperPicker {
                anchors.fill: parent
            }

            Timer {
                interval: 100; running: true; repeat: true
                onTriggered: { if (!ipcPoller.running) ipcPoller.running = true; }
            }

            Process {
                id: ipcPoller
                command: ["bash", "-c", "if [ -f /tmp/wallpicker_state ]; then cat /tmp/wallpicker_state; rm /tmp/wallpicker_state; fi"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        let raw = this.text.trim();
                        if (raw === "") return;
                        let parts = raw.split(":");

                        if (parts[0] === "toggle") {
                            if (mainWindow.visible) {
                                mainWindow.visible = false;
                            } else {
                                mainWindow.visible = true;
                            }
                        } else if (parts[0] === "close") {
                            mainWindow.visible = false;
                        }
                    }
                }
            }
        }
    }
  '';

  matugen-colors-qml = pkgs.writeText "MatugenColors.qml" ''
    import QtQuick

    Item {
        id: root
        property color base: "#1e1e2e"
        property color mantle: "#181825"
        property color crust: "#11111b"
        property color text: "#cdd6f4"
        property color subtext0: "#a6adc8"
        property color subtext1: "#bac2de"
        property color surface0: "#313244"
        property color surface1: "#45475a"
        property color surface2: "#585b70"
        property color overlay0: "#6c7086"
        property color overlay1: "#7f849c"
        property color overlay2: "#9399b2"
        property color blue: "#89b4fa"
        property color sapphire: "#74c7ec"
        property color peach: "#fab387"
        property color green: "#a6e3a1"
        property color red: "#f38ba8"
        property color mauve: "#cba6f7"
        property color pink: "#f5c2e7"
        property color yellow: "#f9e2af"
        property color maroon: "#eba0ac"
        property color teal: "#94e2d5"
    }
  '';

  wallpicker-qml = pkgs.runCommand "wallpicker-qml" {} ''
    mkdir -p $out
    cp ${shell-qml} $out/shell.qml
    cp ${matugen-colors-qml} $out/MatugenColors.qml
    cp ${./WallpaperPicker.qml} $out/WallpaperPicker.qml
  '';

  wallpicker-service = pkgs.writeShellScript "wallpicker-service" ''
    export PATH="${lib.makeBinPath (scriptDeps ++ (with pkgs; [quickshell mpvpaper hyprland jq awww matugen procps waybar]))}:${ddg-search}/bin:${generate-thumbs}/bin:$PATH"
    exec quickshell -p "${wallpicker-qml}"
  '';
in {
  config = lib.mkIf config.my.wayland.hyprland.enable {
    home.packages = [
      pkgs.quickshell
      toggle-wallpicker
      ddg-search
      generate-thumbs
    ];

    systemd.user.services.wallpaper-picker = {
      Unit = {
        Description = "Wallpaper Picker (Quickshell)";
        After = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service = {
        Type = "simple";
        ExecStart = "${wallpicker-service}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    wayland.windowManager.hyprland.settings = {
      layerrule = [
        "match:namespace ^(wallpaper-picker)$, blur 0"
        "match:namespace ^(wallpaper-picker)$, animation none"
      ];

      bind = [
        "$mod SHIFT, W, exec, toggle-wallpicker"
      ];
    };
  };
}

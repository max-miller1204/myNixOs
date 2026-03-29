{ self, inputs, ... }: let
  primaryMonitor = "eDP-1";
  secondaryMonitor = "DP-3";
in {
  flake.nixosModules.niri = { pkgs, lib, config, ... }: {
    options.features.niri.enable = lib.mkEnableOption "Niri compositor with custom config";

    config = lib.mkIf config.features.niri.enable {
      programs.niri = {
        enable = true;
        useNautilus = false;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };

      xdg.portal = {
        xdgOpenUsePortal = true;
        config.common.default = [ "gtk" ];
      };
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      v2-settings = true;
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        # Monitor layout: external (right of internal) is primary
        outputs.${primaryMonitor} = {
          position = _: { props = { x = 0; y = 0; }; };
        };
        # External monitor (to the right of built-in)
        outputs.${secondaryMonitor} = {
          focus-at-startup = _: {};
          position = _: { props = { x = 1755; y = 0; }; };  # after eDP-1 logical width at 1.75 scale
        };

        # Allow client-side transparency (e.g. Alacritty opacity)
        window-rules = [
          {
            clip-to-geometry = true;
            draw-border-with-background = false;
          }
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "us,ua";
        layout.gaps = 5;
        layout.focus-ring.off = _: {};
        layout.border.width = 2;
        layout.border.active-color = "#cba6f7";
        layout.border.inactive-color = "#585b70";

        binds = {
          # --- Your custom binds ---
          "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

          # --- Default niri binds ---

          # Hotkey overlay
          "Mod+Shift+Slash".show-hotkey-overlay = _: {};

          # Screen reader toggle
          "Super+Alt+S" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "pkill orca || exec orca"; };
          };

          # Volume (PipeWire / WirePlumber)
          "XF86AudioRaiseVolume" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; };
          };
          "XF86AudioLowerVolume" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; };
          };
          "XF86AudioMute" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
          };
          "XF86AudioMicMute" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; };
          };

          # Media keys (playerctl)
          "XF86AudioPlay" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "playerctl play-pause"; };
          };
          "XF86AudioStop" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "playerctl stop"; };
          };
          "XF86AudioPrev" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "playerctl previous"; };
          };
          "XF86AudioNext" = _: {
            props = { allow-when-locked = true; };
            content = { spawn-sh = "playerctl next"; };
          };

          # Brightness (brightnessctl)
          "XF86MonBrightnessUp" = _: {
            props = { allow-when-locked = true; };
            content = { spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "+10%" ]; };
          };
          "XF86MonBrightnessDown" = _: {
            props = { allow-when-locked = true; };
            content = { spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "10%-" ]; };
          };

          # Overview
          "Mod+O" = _: {
            props = { repeat = false; };
            content = { toggle-overview = _: {}; };
          };

          # Close window
          "Mod+Q" = _: {
            props = { repeat = false; };
            content = { close-window = _: {}; };
          };

          # Focus movement
          "Mod+Left".focus-column-left = _: {};
          "Mod+Down".focus-window-down = _: {};
          "Mod+Up".focus-window-up = _: {};
          "Mod+Right".focus-column-right = _: {};
          "Mod+H".focus-column-left = _: {};
          "Mod+J".focus-window-down = _: {};
          "Mod+K".focus-window-up = _: {};
          "Mod+L".focus-column-right = _: {};

          # Move windows
          "Mod+Ctrl+Left".move-column-left = _: {};
          "Mod+Ctrl+Down".move-window-down = _: {};
          "Mod+Ctrl+Up".move-window-up = _: {};
          "Mod+Ctrl+Right".move-column-right = _: {};
          "Mod+Ctrl+H".move-column-left = _: {};
          "Mod+Ctrl+J".move-window-down = _: {};
          "Mod+Ctrl+K".move-window-up = _: {};
          "Mod+Ctrl+L".move-column-right = _: {};

          # Focus first/last column
          "Mod+Home".focus-column-first = _: {};
          "Mod+End".focus-column-last = _: {};
          "Mod+Ctrl+Home".move-column-to-first = _: {};
          "Mod+Ctrl+End".move-column-to-last = _: {};

          # Focus monitor
          "Mod+Shift+Left".focus-monitor-left = _: {};
          "Mod+Shift+Down".focus-monitor-down = _: {};
          "Mod+Shift+Up".focus-monitor-up = _: {};
          "Mod+Shift+Right".focus-monitor-right = _: {};
          "Mod+Shift+H".focus-monitor-left = _: {};
          "Mod+Shift+J".focus-monitor-down = _: {};
          "Mod+Shift+K".focus-monitor-up = _: {};
          "Mod+Shift+L".focus-monitor-right = _: {};

          # Move column to monitor
          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = _: {};
          "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = _: {};
          "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = _: {};
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = _: {};
          "Mod+Shift+Ctrl+H".move-column-to-monitor-left = _: {};
          "Mod+Shift+Ctrl+J".move-column-to-monitor-down = _: {};
          "Mod+Shift+Ctrl+K".move-column-to-monitor-up = _: {};
          "Mod+Shift+Ctrl+L".move-column-to-monitor-right = _: {};

          # Focus workspace
          "Mod+Page_Down".focus-workspace-down = _: {};
          "Mod+Page_Up".focus-workspace-up = _: {};
          "Mod+U".focus-workspace-down = _: {};
          "Mod+I".focus-workspace-up = _: {};

          # Move column to workspace
          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = _: {};
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up = _: {};
          "Mod+Ctrl+U".move-column-to-workspace-down = _: {};
          "Mod+Ctrl+I".move-column-to-workspace-up = _: {};

          # Move workspace itself
          "Mod+Shift+Page_Down".move-workspace-down = _: {};
          "Mod+Shift+Page_Up".move-workspace-up = _: {};
          "Mod+Shift+U".move-workspace-down = _: {};
          "Mod+Shift+I".move-workspace-up = _: {};

          # Mouse wheel workspace/column navigation
          "Mod+WheelScrollDown" = _: {
            props = { cooldown-ms = 150; };
            content = { focus-workspace-down = _: {}; };
          };
          "Mod+WheelScrollUp" = _: {
            props = { cooldown-ms = 150; };
            content = { focus-workspace-up = _: {}; };
          };
          "Mod+Ctrl+WheelScrollDown" = _: {
            props = { cooldown-ms = 150; };
            content = { move-column-to-workspace-down = _: {}; };
          };
          "Mod+Ctrl+WheelScrollUp" = _: {
            props = { cooldown-ms = 150; };
            content = { move-column-to-workspace-up = _: {}; };
          };
          "Mod+WheelScrollRight".focus-column-right = _: {};
          "Mod+WheelScrollLeft".focus-column-left = _: {};
          "Mod+Ctrl+WheelScrollRight".move-column-right = _: {};
          "Mod+Ctrl+WheelScrollLeft".move-column-left = _: {};
          "Mod+Shift+WheelScrollDown".focus-column-right = _: {};
          "Mod+Shift+WheelScrollUp".focus-column-left = _: {};
          "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = _: {};
          "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = _: {};

          # Workspace by number
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          # Move column to workspace by number
          "Mod+Ctrl+1".move-column-to-workspace = 1;
          "Mod+Ctrl+2".move-column-to-workspace = 2;
          "Mod+Ctrl+3".move-column-to-workspace = 3;
          "Mod+Ctrl+4".move-column-to-workspace = 4;
          "Mod+Ctrl+5".move-column-to-workspace = 5;
          "Mod+Ctrl+6".move-column-to-workspace = 6;
          "Mod+Ctrl+7".move-column-to-workspace = 7;
          "Mod+Ctrl+8".move-column-to-workspace = 8;
          "Mod+Ctrl+9".move-column-to-workspace = 9;

          # Consume / expel windows
          "Mod+BracketLeft".consume-or-expel-window-left = _: {};
          "Mod+BracketRight".consume-or-expel-window-right = _: {};
          "Mod+Comma".consume-window-into-column = _: {};
          "Mod+Period".expel-window-from-column = _: {};

          # Resize
          "Mod+R".switch-preset-column-width = _: {};
          "Mod+Shift+R".switch-preset-window-height = _: {};
          "Mod+Ctrl+R".reset-window-height = _: {};
          "Mod+F".maximize-column = _: {};
          "Mod+Shift+F".fullscreen-window = _: {};
          "Mod+M".maximize-window-to-edges = _: {};
          "Mod+Ctrl+F".expand-column-to-available-width = _: {};
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          # Center
          "Mod+C".center-column = _: {};
          "Mod+Ctrl+C".center-visible-columns = _: {};

          # Floating / tiling
          "Mod+V".toggle-window-floating = _: {};
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = _: {};

          # Tabbed columns
          "Mod+W".toggle-column-tabbed-display = _: {};

          # Screenshots
          "Print".screenshot = _: {};
          "Ctrl+Print".screenshot-screen = _: {};
          "Alt+Print".screenshot-window = _: {};

          # Keyboard shortcuts inhibitor escape hatch
          "Mod+Escape" = _: {
            props = { allow-inhibiting = false; };
            content = { toggle-keyboard-shortcuts-inhibit = _: {}; };
          };

          # Quit
          "Mod+Shift+E".quit = _: {};
          "Ctrl+Alt+Delete".quit = _: {};

          # Power off monitors
          "Mod+Shift+P".power-off-monitors = _: {};
        };
      };
    };
  };
}

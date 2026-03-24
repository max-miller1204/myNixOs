{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      settings = {
        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "us,ua";
        layout.gaps = 5;
        layout.focus-ring.off = null;

        binds = {
          # --- Your custom binds ---
          "Mod+Return".spawn-sh = lib.getExe pkgs.alacritty;
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

          # --- Default niri binds ---

          # Hotkey overlay
          "Mod+Shift+Slash".show-hotkey-overlay = null;

          # Screen reader toggle
          "Super+Alt+S" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "pkill orca || exec orca";
          };

          # Volume (PipeWire / WirePlumber)
          "XF86AudioRaiseVolume" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          };
          "XF86AudioLowerVolume" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          };
          "XF86AudioMute" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          "XF86AudioMicMute" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };

          # Media keys (playerctl)
          "XF86AudioPlay" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "playerctl play-pause";
          };
          "XF86AudioStop" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "playerctl stop";
          };
          "XF86AudioPrev" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "playerctl previous";
          };
          "XF86AudioNext" = {
            _attrs = { allow-when-locked = true; };
            spawn-sh = "playerctl next";
          };

          # Brightness (brightnessctl)
          "XF86MonBrightnessUp" = {
            _attrs = { allow-when-locked = true; };
            spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "+10%" ];
          };
          "XF86MonBrightnessDown" = {
            _attrs = { allow-when-locked = true; };
            spawn = [ (lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "10%-" ];
          };

          # Overview
          "Mod+O" = {
            _attrs = { repeat = false; };
            toggle-overview = null;
          };

          # Close window
          "Mod+Q" = {
            _attrs = { repeat = false; };
            close-window = null;
          };

          # Focus movement
          "Mod+Left".focus-column-left = null;
          "Mod+Down".focus-window-down = null;
          "Mod+Up".focus-window-up = null;
          "Mod+Right".focus-column-right = null;
          "Mod+H".focus-column-left = null;
          "Mod+J".focus-window-down = null;
          "Mod+K".focus-window-up = null;
          "Mod+L".focus-column-right = null;

          # Move windows
          "Mod+Ctrl+Left".move-column-left = null;
          "Mod+Ctrl+Down".move-window-down = null;
          "Mod+Ctrl+Up".move-window-up = null;
          "Mod+Ctrl+Right".move-column-right = null;
          "Mod+Ctrl+H".move-column-left = null;
          "Mod+Ctrl+J".move-window-down = null;
          "Mod+Ctrl+K".move-window-up = null;
          "Mod+Ctrl+L".move-column-right = null;

          # Focus first/last column
          "Mod+Home".focus-column-first = null;
          "Mod+End".focus-column-last = null;
          "Mod+Ctrl+Home".move-column-to-first = null;
          "Mod+Ctrl+End".move-column-to-last = null;

          # Focus monitor
          "Mod+Shift+Left".focus-monitor-left = null;
          "Mod+Shift+Down".focus-monitor-down = null;
          "Mod+Shift+Up".focus-monitor-up = null;
          "Mod+Shift+Right".focus-monitor-right = null;
          "Mod+Shift+H".focus-monitor-left = null;
          "Mod+Shift+J".focus-monitor-down = null;
          "Mod+Shift+K".focus-monitor-up = null;
          "Mod+Shift+L".focus-monitor-right = null;

          # Move column to monitor
          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = null;
          "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = null;
          "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = null;
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = null;
          "Mod+Shift+Ctrl+H".move-column-to-monitor-left = null;
          "Mod+Shift+Ctrl+J".move-column-to-monitor-down = null;
          "Mod+Shift+Ctrl+K".move-column-to-monitor-up = null;
          "Mod+Shift+Ctrl+L".move-column-to-monitor-right = null;

          # Focus workspace
          "Mod+Page_Down".focus-workspace-down = null;
          "Mod+Page_Up".focus-workspace-up = null;
          "Mod+U".focus-workspace-down = null;
          "Mod+I".focus-workspace-up = null;

          # Move column to workspace
          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = null;
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up = null;
          "Mod+Ctrl+U".move-column-to-workspace-down = null;
          "Mod+Ctrl+I".move-column-to-workspace-up = null;

          # Move workspace itself
          "Mod+Shift+Page_Down".move-workspace-down = null;
          "Mod+Shift+Page_Up".move-workspace-up = null;
          "Mod+Shift+U".move-workspace-down = null;
          "Mod+Shift+I".move-workspace-up = null;

          # Mouse wheel workspace/column navigation
          "Mod+WheelScrollDown" = {
            _attrs = { cooldown-ms = 150; };
            focus-workspace-down = null;
          };
          "Mod+WheelScrollUp" = {
            _attrs = { cooldown-ms = 150; };
            focus-workspace-up = null;
          };
          "Mod+Ctrl+WheelScrollDown" = {
            _attrs = { cooldown-ms = 150; };
            move-column-to-workspace-down = null;
          };
          "Mod+Ctrl+WheelScrollUp" = {
            _attrs = { cooldown-ms = 150; };
            move-column-to-workspace-up = null;
          };
          "Mod+WheelScrollRight".focus-column-right = null;
          "Mod+WheelScrollLeft".focus-column-left = null;
          "Mod+Ctrl+WheelScrollRight".move-column-right = null;
          "Mod+Ctrl+WheelScrollLeft".move-column-left = null;
          "Mod+Shift+WheelScrollDown".focus-column-right = null;
          "Mod+Shift+WheelScrollUp".focus-column-left = null;
          "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = null;
          "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = null;

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
          "Mod+BracketLeft".consume-or-expel-window-left = null;
          "Mod+BracketRight".consume-or-expel-window-right = null;
          "Mod+Comma".consume-window-into-column = null;
          "Mod+Period".expel-window-from-column = null;

          # Resize
          "Mod+R".switch-preset-column-width = null;
          "Mod+Shift+R".switch-preset-window-height = null;
          "Mod+Ctrl+R".reset-window-height = null;
          "Mod+F".maximize-column = null;
          "Mod+Shift+F".fullscreen-window = null;
          "Mod+M".maximize-window-to-edges = null;
          "Mod+Ctrl+F".expand-column-to-available-width = null;
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          # Center
          "Mod+C".center-column = null;
          "Mod+Ctrl+C".center-visible-columns = null;

          # Floating / tiling
          "Mod+V".toggle-window-floating = null;
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = null;

          # Tabbed columns
          "Mod+W".toggle-column-tabbed-display = null;

          # Screenshots
          "Print".screenshot = null;
          "Ctrl+Print".screenshot-screen = null;
          "Alt+Print".screenshot-window = null;

          # Keyboard shortcuts inhibitor escape hatch
          "Mod+Escape" = {
            _attrs = { allow-inhibiting = false; };
            toggle-keyboard-shortcuts-inhibit = null;
          };

          # Quit
          "Mod+Shift+E".quit = null;
          "Ctrl+Alt+Delete".quit = null;

          # Power off monitors
          "Mod+Shift+P".power-off-monitors = null;
        };
      };
    };
  };
}

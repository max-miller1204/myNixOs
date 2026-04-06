{ self, inputs, ... }: {
  den.aspects.tmux = {
    homeManager = { pkgs, ... }: {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
        terminal = "tmux-256color";
        mouse = true;
        keyMode = "vi";
        baseIndex = 1;         # Windows start at 1, not 0
        escapeTime = 0;        # No delay after pressing Escape
        historyLimit = 50000;

        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank           # System clipboard integration
          catppuccin     # Match your theme
        ];

        extraConfig = ''
          # -- Prefix -----------------------------------------------------------
          # Remap prefix to Ctrl-a (easier to reach than Ctrl-b)
          unbind C-b
          set -g prefix C-a
          bind C-a send-prefix

          # -- Pane splitting ---------------------------------------------------
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # New windows keep the current path
          bind c new-window -c "#{pane_current_path}"

          # -- Pane navigation (vim-style) --------------------------------------
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          # -- Pane resizing (hold prefix + arrow) ------------------------------
          bind -r H resize-pane -L 5
          bind -r J resize-pane -D 5
          bind -r K resize-pane -U 5
          bind -r L resize-pane -R 5

          # -- Quality of life --------------------------------------------------
          set -g renumber-windows on     # Re-number when a window is closed
          set -g set-titles on
          set -g set-titles-string "#S / #W"
          set -g focus-events on         # Needed for some editor integrations
          set -sa terminal-features ',alacritty:RGB'  # True color in Alacritty

          # -- Status bar tweaks ------------------------------------------------
          set -g status-position top
        '';
      };
    };
  };
}

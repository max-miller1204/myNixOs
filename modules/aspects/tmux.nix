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
          unbind C-b
          set -g prefix C-a
          bind C-a send-prefix

          # Reload config
          bind q source-file ~/.config/tmux/tmux.conf \; display "Configuration reloaded"

          # Vi mode for copy
          bind -T copy-mode-vi v send -X begin-selection
          bind -T copy-mode-vi y send -X copy-selection-and-cancel

          # Pane Controls
          bind h split-window -v -c "#{pane_current_path}"
          bind v split-window -h -c "#{pane_current_path}"
          bind x kill-pane

          bind -n C-M-Left select-pane -L
          bind -n C-M-Right select-pane -R
          bind -n C-M-Up select-pane -U
          bind -n C-M-Down select-pane -D

          bind -n C-M-S-Left resize-pane -L 5
          bind -n C-M-S-Down resize-pane -D 5
          bind -n C-M-S-Up resize-pane -U 5
          bind -n C-M-S-Right resize-pane -R 5

          # Window navigation
          bind r command-prompt -I "#W" "rename-window -- '%%'"
          bind c new-window -c "#{pane_current_path}"
          bind k kill-window

          bind -n M-1 select-window -t 1
          bind -n M-2 select-window -t 2
          bind -n M-3 select-window -t 3
          bind -n M-4 select-window -t 4
          bind -n M-5 select-window -t 5
          bind -n M-6 select-window -t 6
          bind -n M-7 select-window -t 7
          bind -n M-8 select-window -t 8
          bind -n M-9 select-window -t 9

          bind -n M-Left select-window -t -1
          bind -n M-Right select-window -t +1
          bind -n M-S-Left swap-window -t -1 \; select-window -t -1
          bind -n M-S-Right swap-window -t +1 \; select-window -t +1

          # Session controls
          bind R command-prompt -I "#S" "rename-session -- '%%'"
          bind C new-session -c "#{pane_current_path}"
          bind K kill-session
          bind P switch-client -p
          bind N switch-client -n

          bind -n M-Up switch-client -p
          bind -n M-Down switch-client -n

          # General
          set -ag terminal-overrides ",*:RGB"
          setw -g pane-base-index 1
          set -g renumber-windows on
          set -g focus-events on
          set -g set-clipboard on
          set -g allow-passthrough on
          setw -g aggressive-resize on
          set -g detach-on-destroy off
          set -g set-titles on
          set -g set-titles-string "#S / #W"
          set -sa terminal-features ',alacritty:RGB'

          # Status bar
          set -g status-position top
          set -g status-interval 5
          set -g status-left-length 30
          set -g status-right-length 50
          set -g window-status-separator ""
          set -gw automatic-rename on
          set -gw automatic-rename-format '#{b:pane_current_path}'
        '';
      };
    };
  };
}

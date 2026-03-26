# Catppuccin Theming

## Flavor and accent

- **Flavor**: Mocha (darkest)
- **Accent**: Mauve (purple)

These are defined in `config.my.variables.catppuccin.flavor` and
`config.my.variables.catppuccin.accent` — change them in `variables.nix`
to switch the entire system's theme.

## What's themed

### Auto-themed by catppuccin/nix (Home Manager module)

These programs are configured via HM `programs.*` and the catppuccin HM module
auto-applies the theme:

- Fish shell
- Starship prompt
- bat
- fzf
- Cursors (catppuccin-cursors.mochaMauve)

### Manually themed (wrapper-modules packages)

These are built via wrapper-modules, which bypasses Home Manager. Catppuccin
colors are added as hex values directly in their settings:

- **Alacritty** (`alacritty.nix`) — full Mocha color palette (16 colors + cursor + selection)
- **Niri** (`niri.nix`) — `active-color = "#cba6f7"` (mauve), `inactive-color = "#585b70"` (surface2)

### Qt apps

Qt apps are themed via Kvantum (`qt.platformTheme.name = "kvantum"`). The
catppuccin/nix module auto-applies the Catppuccin Kvantum theme.

### GTK/libadwaita apps

The upstream Catppuccin GTK port was archived, so GTK apps can't be directly
themed by catppuccin/nix. Instead, `dconf` sets `color-scheme = "prefer-dark"`
which forces all libadwaita/GTK4 apps into dark mode. This pairs well with
the Mocha theme on everything else.

## How it's structured

`modules/features/catppuccin.nix` has two levels:

1. **NixOS level**: Imports `inputs.catppuccin.nixosModules.catppuccin`, sets
   system-wide flavor and accent
2. **Home Manager level**: Imports `inputs.catppuccin.homeModules.catppuccin`,
   enables cursors, Qt/Kvantum theming, dark mode dconf setting, and
   auto-themes all HM-managed programs

## Changing the theme

Edit `modules/features/variables.nix`:

```nix
catppuccin = {
  flavor = "frappe";    # latte, frappe, macchiato, mocha
  accent = "blue";      # rosewater, flamingo, pink, mauve, red, maroon,
                        # peach, yellow, green, teal, sky, sapphire, blue, lavender
};
```

Then manually update the hex values in `alacritty.nix` and `niri.nix` to match
the new flavor. Color references: https://catppuccin.com/palette

## Flake input

```nix
# flake.nix
catppuccin = {
  url = "github:catppuccin/nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

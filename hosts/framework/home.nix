# Home-manager for the Framework laptop only, on top of modules/home (shared
# with fruitbox): its packages, the desktop look, and the wayland/desktop
# configs. flake.nix adds it for this host, so nothing here needs an isLinux
# guard.
{ config, pkgs, ... }:
let
  inherit (import ../../modules/home/links.nix { inherit config; }) link links;
in
{
  # On the Mac these come from Homebrew (modules/darwin/homebrew.nix).
  home.packages = with pkgs; [
    neovim
    tmux
    fzf
    ripgrep
    fd
    bat
    wget
    pyenv
    fnm
    claude-code
    # vim-fugitive runs git through hub (config/nvim/lua/plugins/init.lua)
    hub

    # nvim-treesitter (main branch) compiles every parser locally:
    # it needs the tree-sitter CLI and a C compiler
    tree-sitter
    gcc
    # mason installs ts_ls and vimls with npm, and ruff, ty, black and flake8
    # into python venvs; fnm and pyenv provide neither until a version is set up
    nodejs
    python3
    # ...and unpacks zip releases (terraform-ls, stylua) with unzip
    unzip

    # configs linked by modules/home
    alacritty
    qutebrowser
    zathura
  ];

  # Look for GTK apps (thunar, zen's dialogs, ...). nixpkgs has no solarized
  # GTK theme any more (they needed the removed GTK2 murrine engine), so: dark
  # Adwaita, Papirus icons as on piecyk, and config/gtk/solarized.css on top for
  # GTK3 (linked below as gtk-3.0/gtk.css). colorScheme also sets the
  # prefer-dark that libadwaita/GTK4 apps read, since they ignore gtk themes.
  # piecyk's config/gtk-3.0 is left to bootstrap.sh, not linked here.
  gtk = {
    enable = true;
    colorScheme = "dark";
    # proportional for file names and dialogs: DejaVu Sans, the same family and
    # size (10pt, ~13px) as the mono font in waybar, alacritty and rofi
    font = {
      name = "DejaVu Sans";
      package = pkgs.dejavu_fonts;
      size = 10;
    };
    theme.name = "Adwaita-dark";
    # GTK4/libadwaita: the dark colorScheme only; a forced theme breaks them
    gtk4.theme = null;
    iconTheme = {
      name = "Papirus-Dark";
      # folders recoloured near solarized cyan (#2aa198) instead of Papirus' bright blue
      package = pkgs.papirus-icon-theme.override { color = "darkcyan"; };
    };
  };

  # Cursor for everything: also writes ~/.icons/default, which is where X/
  # Wayland clients and hyprland look when no theme is named.
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # The wayland desktop's configs. The X11/awesome set (awesome, dunst, gtk-*,
  # Kvantum, qt5ct, Thunar, systemd) is still left to bootstrap.sh, for piecyk.
  xdg.configFile =
    links "config" [
      # hyprland reads hyprland.lua in preference to hyprland.conf as of 0.55
      "hypr"
      "waybar"
      "mako"
      "rofi"
      "networkmanager-dmenu"
    ]
    // {
      # one file, not gtk-3.0/: the gtk module writes settings.ini there
      "gtk-3.0/gtk.css".source = link "config/gtk/solarized.css";
      # alacritty.toml imports this after its default font-size.toml
      "alacritty-host.toml".source = link "config/alacritty/framework.toml";
      # zen: solarized browser UI. Into the profile zen created on first run
      # (profiles.ini); a new profile means a new name here.
      "zen/i2nvrf4n.Default Profile/chrome/userChrome.css".source = link "config/zen/userChrome.css";
      "zen/i2nvrf4n.Default Profile/user.js".source = link "config/zen/user.js";
    };
}

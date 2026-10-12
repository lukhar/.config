{ config, ... }:
let
  # The checkout, not the store. Everything below links *out* of the store with
  # mkOutOfStoreSymlink so these stay editable in place and git-tracked -- which
  # is what bootstrap.sh does by hand, and nvim in particular needs: lazy writes
  # lazy-lock.json and harper writes the dictionary.
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = "lharatym";
  home.homeDirectory = "/Users/lharatym";
  home.stateVersion = "25.05";

  # Sets XDG_CONFIG_HOME and friends. The per-tool variables that XDG_* does not
  # move on its own still come from config/shell/xdg.sh, sourced by the shells.
  xdg.enable = true;

  # Directories home-manager has taken over from bootstrap.sh. Everything uses
  # link (mkOutOfStoreSymlink) rather than a store copy, so the files stay
  # editable in the checkout -- several of these are written at runtime.
  #
  # bootstrap.sh still links the full set, because piecyk has no home-manager
  # and needs them; the two mechanisms coexist, and home-manager simply takes
  # ownership of a link on activation.
  #
  # Linux-only directories (awesome, rofi, dunst, gtk-*, Kvantum, qt5ct, Thunar,
  # systemd) are left to bootstrap.sh until there is a modules/home/linux.
  xdg.configFile = builtins.listToAttrs (
    map (name: {
      inherit name;
      value.source = link "config/${name}";
    }) [
      "nvim"

      "alacritty"
      "bat"
      "ctags"
      "fontconfig"
      "ghostty"
      "mc"
      "mpv"
      "ptpython"
      "qutebrowser"
      "zathura"
    ]
  );
}

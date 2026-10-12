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

  # Start with one directory, to prove the pipeline end to end before moving the
  # other 34 over. nvim is the useful first case: it is the one that must stay
  # writable, so if mkOutOfStoreSymlink is wrong here it shows up immediately.
  xdg.configFile."nvim".source = link "config/nvim";
}

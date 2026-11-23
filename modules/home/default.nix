{ config, ... }:
let
  inherit (import ./links.nix { inherit config; }) link links;
in
{
  # Shared by every nix host (fruitbox, framework); per-host additions live
  # next to the host, e.g. hosts/framework/home.nix.
  #
  # username and homeDirectory are inferred from the home-manager.users.<name>
  # key and the platform, so this module serves both hosts unchanged. On NixOS
  # that inference reads users.users.<name>.home, so the host has to declare the
  # account -- otherwise home lands on /var/empty and activation fails there.
  home.stateVersion = "25.05";

  # Sets XDG_CONFIG_HOME and friends. The per-tool variables that XDG_* does not
  # move on its own still come from config/shell/xdg.sh, sourced by the shells.
  xdg.enable = true;

  # Directories home-manager has taken over from bootstrap.sh.
  #
  # bootstrap.sh still links the full set, because piecyk has no home-manager
  # and needs them; the two mechanisms coexist, and home-manager simply takes
  # ownership of a link on activation.
  xdg.configFile =
    links "config" [
      "nvim"

      "alacritty"
      "bat"
      "ctags"
      "ghostty"
      "mc"
      "mpv"
      "ptpython"
      "qutebrowser"
      "zathura"

      # batch 2. shell/ and bin/ are load-bearing: $XDG_CONFIG_HOME/shell/xdg.sh
      # is sourced by every shell and bin/ is on PATH, so they resolve through
      # home-manager from here on.
      "ag"
      "aiassist"
      "bin"
      "git"
      "shell"
      "tmux"

      # batch 3, on its own. ~/.zshenv points at config/zsh/.zshenv and that
      # file sets ZDOTDIR, so if this link breaks zsh starts with no
      # configuration at all -- no ZDOTDIR, no .zshrc. Nothing here enables
      # home-manager's programs.zsh: it would fight the ZDOTDIR arrangement.
      "zsh"
    ]

    // {
      # fontconfig is the one directory home-manager writes into as well: on
      # linux fonts.fontconfig.enable (on by default) generates
      # conf.d/10-hm-fonts.conf, which is what makes fonts from nix packages
      # visible to everything else. Linking the directory does not merely shadow
      # that file, it fails the generation outright -- nothing can be created
      # inside an out-of-store symlink. Only fonts.conf is ours, so only
      # fonts.conf is linked.
      "fontconfig/fonts.conf".source = link "config/fontconfig/fonts.conf";
    };

  # The $HOME holdouts: tools with no XDG support at all. bootstrap.sh links the
  # same five, because piecyk needs them; here they matter because a fresh
  # machine has no bootstrap run behind it -- and .zshenv especially, since it is
  # the one file that sets ZDOTDIR. Without it zsh never finds config/zsh at all.
  home.file =
    links "home" [
      ".bashrc"
      ".bash_profile"
      ".profile"
      ".inputrc"
      ".Xresources" # inert on darwin; merged by the display manager on linux
    ]
    // {
      ".zshenv".source = link "config/zsh/.zshenv";
    }
    # Claude Code does not honour XDG_CONFIG_HOME either; the same three links
    # bootstrap.sh makes, so a fresh machine has the agents, skills and rules.
    // builtins.listToAttrs (
      map
        (d: {
          name = ".claude/${d}";
          value.source = link "config/aiassist/claude/${d}";
        })
        [
          "rules"
          "skills"
          "agents"
        ]
    );
}

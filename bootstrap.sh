#!/bin/bash
# Links this checkout into place. Safe to re-run.
#
# The repository used to *be* $XDG_CONFIG_HOME, so most tools found their config
# with no indirection. Now that it lives anywhere, each config/<app> is linked to
# $XDG_CONFIG_HOME/<app> instead -- which is the job home-manager takes over on
# the hosts that get it.

set -eu

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$XDG_CONFIG_HOME" ~/bin ~/sdk ~/.cache/vim/swp ~/.cache/vim/undo
mkdir -p ~/.claude # the aiassist links below land inside it

# Every config/<app> becomes $XDG_CONFIG_HOME/<app>.
#
# A real file or directory already at the destination is left alone and reported
# rather than replaced: on a machine that predates this layout every
# ~/.config/<app> exists for real, and `ln -sfn` would quietly nest the new link
# *inside* it. Move or delete the original, then re-run.
# X11, GTK/Qt theming and the Arch/XFCE bits: linking these on macOS creates
# fourteen symlinks nothing will ever read. They move to a home-manager module
# the Linux hosts import once the NixOS laptop exists.
linux_only="awesome rofi dunst gtk-2.0 gtk-3.0 Kvantum qt5ct Thunar systemd
            compton.conf i3-scrot.conf mimeapps.list pikaur.conf user-dirs.dirs"

skipped=""
for src in "$REPO"/config/*; do
  name="$(basename "$src")"
  dest="$XDG_CONFIG_HOME/$name"

  if [ "$(uname -s)" = Darwin ]; then
    case " $(echo $linux_only) " in *" $name "*) continue ;; esac
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    skipped="$skipped  $dest\n"
    continue
  fi
  ln -sfn "$src" "$dest"
done

if [ -n "$skipped" ]; then
  printf 'left in place (not symlinked), move or remove these and re-run:\n%b' "$skipped"
fi

# The holdouts: tools that hardcode a path in $HOME.
#   bash and readline have no XDG support at all
#   .Xresources is merged from here by the display manager
for f in .bashrc .bash_profile .profile .inputrc .Xresources; do
  ln -sf "$REPO/home/$f" "$HOME/$f"
done

# zsh needs exactly one file in $HOME; it sets ZDOTDIR and finds the rest itself
ln -sf "$XDG_CONFIG_HOME/zsh/.zshenv" "$HOME/.zshenv"

# Claude Code does not honour XDG_CONFIG_HOME
for d in rules skills agents; do
  ln -sfn "$REPO/config/aiassist/claude/$d" "$HOME/.claude/$d"
done

# poetry's completion embeds an absolute path, so generate it per machine
if command -v poetry >/dev/null; then
  poetry completions zsh > "$REPO/config/zsh/completions/_poetry"
fi

if [ "$(uname -s)" = Darwin ] && [ -d ~/Dropbox/Shared ]; then
  ln -sfn ~/Dropbox/Shared ~/Documents/shared
fi

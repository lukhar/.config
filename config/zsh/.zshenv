# Read as $HOME/.zshenv via symlink, before ZDOTDIR exists -- which is why the
# XDG bootstrap has to happen here. zsh does not re-read .zshenv from $ZDOTDIR
# afterwards, so this file is loaded exactly once despite pointing at itself.

# Literal path: $XDG_CONFIG_HOME is what this file is about to define.
. "$HOME/.config/shell/xdg.sh"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

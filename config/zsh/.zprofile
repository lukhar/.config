# Setting ZDOTDIR makes ~/.zprofile inert, so the login-shell setup moved here.
# Guarded throughout so the same file is safe on piecyk, where none of it exists.

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv is brew-installed, so this resolves only after shellenv above.
#
# --no-rehash matters: without it `pyenv init --path` ends with `pyenv rehash`,
# which rebuilds every shim -- 340 of them across 42 versions and virtualenvs,
# 681ms measured -- on every login shell. Since tmux panes became login shells
# that was the whole of the lag on splitting a pane. pyenv install and pyenv
# virtualenv rehash on their own, so the only thing lost is picking up a shim
# for something installed by other means, which `pyenv rehash` fixes by hand.
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init --path --no-rehash)"

# pipx
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

# OrbStack command-line tools
[ -f "$HOME/.orbstack/shell/init.zsh" ] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

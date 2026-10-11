# Setting ZDOTDIR makes ~/.zprofile inert, so the login-shell setup moved here.
# Guarded throughout so the same file is safe on piecyk, where none of it exists.

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv is brew-installed, so this resolves only after shellenv above
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init --path)"

# pipx
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

# OrbStack command-line tools
[ -f "$HOME/.orbstack/shell/init.zsh" ] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

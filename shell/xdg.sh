# Single definition of the XDG environment, kept POSIX-clean so sh, bash and zsh
# can all source it: zsh from zsh/.zshenv, bash from .bashrc and .bash_profile,
# plain sh from .profile.
#
# Bash has no XDG support of its own -- there is no mention of XDG in its manual
# or its binary -- so anything that should not land in $HOME has to be pointed
# somewhere explicitly, per tool. Same for most CLI tools; XDG_* alone moves
# nothing.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
# XDG_RUNTIME_DIR is deliberately absent: pam_systemd provides it on Linux and
# there is no sane macOS equivalent.

export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history" # python 3.13+
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

export EDITOR=nvim

# ~/Documents is capitalised on macOS and lowercase on Linux, and APFS being
# case-insensitive hides getting it wrong until the config reaches piecyk.
if [ "$(uname -s)" = Darwin ]; then
  export NOTES="$HOME/Documents/shared/notes"
else
  export NOTES="$HOME/documents/shared/notes"
fi

# None of the above create their parent directory. The -d test keeps this to zero
# forks once they exist.
for _xdg_dir in "$XDG_STATE_HOME/zsh" "$XDG_STATE_HOME/bash" "$XDG_STATE_HOME/less" \
  "$XDG_STATE_HOME/python" "$XDG_STATE_HOME/psql" "$XDG_STATE_HOME/wget" \
  "$XDG_CACHE_HOME/zsh" "$XDG_CONFIG_HOME/npm"; do
  [ -d "$_xdg_dir" ] || mkdir -p "$_xdg_dir"
done
unset _xdg_dir

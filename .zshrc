source ~/.zplug/init.zsh
zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
zplug load

zstyle :prompt:pure:git:stash show yes                          # turn on git stash status
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# bigger history
HISTFILE=~/.zhistory
HISTSIZE=500000000
SAVEHIST=5000

# enable editing commands in EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# load aliases
[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases

export PATH=$HOME/bin:$PATH
export NOTES=$HOME/documents/shared/notes
export EDITOR=`which nvim`

# pyenv shell prompt
precmd() {
  if [[ -n $PYENV_SHELL ]]; then
    local version
    version=${(@)$(pyenv version)[1]}
    if [[ $version = system ]]; then
      unset VIRTUAL_ENV
    else
      VIRTUAL_ENV=$version
    fi
  fi
}

# TODO move to separate file
has_bin() {
  which $1 > /dev/null
}

load_pyenv() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
  [ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"
}

load_rbenv() {
  [ -x "$(command -v rbenv)" ] && eval "$(rbenv init -)"
}

load_fzf() {
  [ -d $HOME/.fzf ] && source ~/.fzf.zsh
}

load_hub() {
  [ -x "$(command -v hub)" ] && eval "$(hub alias -s)"
}

load_sdk() {
  [ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh
}

load_pipx() {
  [ -x "$(command -v pipx)" ] && export PATH=$HOME/.local/bin:$PATH
}

load_misc() {
  [ -f $HOME/.poetry/env ] && source $HOME/.poetry/env
  [ -f $HOME/.localrc ] && source $HOME/.localrc
}

init_funcs=(load_pyenv load_rbenv load_fzf load_hub load_pipx load_sdk load_misc)
init_total=${#init_funcs[*]}
init_index=1

# Triggers an init function
# $1: the init function index to trigger
# $2: the number of seconds to wait before triggering
run() {
	sleep ${2:0}
	echo $1
}

async_init
async_start_worker zsh -n

init_callback() {
  if [[ "$1" == "run" ]]
  then
    # Run the current init function
    eval "$init_funcs[$3]"

    # Trigger the next init function. This ensures the init
    # functions runs in serial.
    if (( init_index < init_total ))
    then
      init_index=$(( init_index + 1 ))
      async_job zsh run $init_index 0
    fi
  fi
}
async_register_callback zsh init_callback

# Delay init function triggering for 2s to make the shell starts faster.
async_job zsh run 1 2

#vim: tabstop=2 shiftwidth=2 expandtab

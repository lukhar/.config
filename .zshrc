source ~/.zplug/init.zsh
zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions",  defer:2, on:"zsh-users/zsh-completions"
zplug load

zstyle :prompt:pure:git:stash show yes                          # turn on git stash status
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# bigger history
HISTFILE=~/.zhistory
HISTSIZE=500000000
SAVEHIST=5000

# enable editing commands in EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# use control space for autosuggest completion
bindkey '^ ' autosuggest-accept

# load aliases
[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases

export PATH=$HOME/bin:$PATH
export NOTES=$HOME/documents/shared/notes
export EDITOR=`which nvim`

# pyenv shell prompt
precmd() {
  if [[ -n $PYENV_SHELL ]]; then
    local version
    version=$(pyenv version-name)
    if [[ $version = system ]]; then
      unset VIRTUAL_ENV
    else
      VIRTUAL_ENV=$version
    fi
  fi
}

# TODO move to separate file
__init_pyenv() {
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
  [ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"
}

__init_rbenv() {
  [ -x "$(command -v rbenv)" ] && eval "$(rbenv init -)"
}

__init_nvm() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}

__init_fzf() {
  [ -d $HOME/.fzf ] && source ~/.fzf.zsh
}

__init_hub() {
  [ -x "$(command -v hub)" ] && eval "$(hub alias -s)"
}

__init_sdk() {
  [ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh
}

__init_pipx() {
  [ -x "$(command -v pipx)" ] && export PATH=$HOME/.local/bin:$PATH
}

__init_misc() {
  [ -f $HOME/.poetry/env ] && source $HOME/.poetry/env
  [ -f $HOME/.localrc ] && source $HOME/.localrc
}

__init_funcs=(__init_pyenv __init_rbenv __init_nvm __init_fzf __init_hub __init_pipx __init_sdk __init_misc)
__init_total=${#__init_funcs[*]}
__init_index=1

# Triggers an init function
# $1: the init function index to trigger
# $2: the number of seconds to wait before triggering
__run() {
  sleep ${2:0}
  echo $1
}

async_init
async_start_worker zsh -n

init_callback() {
  if [[ "$1" == "__run" ]]
  then
    # Run the current init function
    eval "$__init_funcs[$3]"

    # Trigger the next init function. This ensures the init
    # functions runs in serial.
    if (( __init_index < __init_total ))
    then
      __init_index=$(( __init_index + 1 ))
      async_job zsh __run $__init_index 0
    fi
  fi
}
async_register_callback zsh init_callback

# Delay init function triggering for 2s to make the shell starts faster.
async_job zsh __run 1 2

#vim: tabstop=2 shiftwidth=2 expandtab

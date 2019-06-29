#!/bin/bash

source $HOME/.config/gradle-completion.bash

if [ $HOSTNAME = fruitbox ]; then
  [ -d $HOME/.qcshext ] && source $HOME/.qcshext/qcrc
  [ -f $(brew --prefix)/etc/bash_completion  ] && . $(brew --prefix)/etc/bash_completion

  export PATH=/usr/local/sbin:$PATH
  export PATH=$HOME/.cargo/bin:$PATH
  export NOTES=$HOME/Documents/shared/notes
  export EDITOR=/usr/local/bin/vim

  export GOPATH=$HOME/sdk/go
  export HOMEBREW_GITHUB_API_TOKEN=2b3edc249b2df92c2e49f267f4d685d4a9c74b7c
fi

if [ "$HOSTNAME" = piecyk ]; then
  source $HOME/.config/.profile
  source $HOME/.config/git-prompt.sh
  source $HOME/.config/git-completion.bash
  export NOTES=$HOME/documents/shared/notes

  # solarized highligthing for ls
  eval `dircolors $HOME/.dircolors`

  # ugly fix for bold fonts in tmux
  alias tmux='TERM=xterm-256color /usr/bin/tmux'

  export PATH=$PYENV_ROOT/bin:$PATH

  [ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
  [ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"

  [ -x "$(command -v hub)" ] && eval "$(hub alias -s)"

  function set_virtualenv () {
    if [[ `pyenv version-name` == "system" ]] ; then
      PYTHON_VIRTUALENV=""
    else
      PYTHON_VIRTUALENV="(`pyenv version-name`) "
    fi
  }

  function set_terraform_workspace () {
    if [ -d .terraform ] ; then
      TERRAFORM_WORKSPACE="[`terraform workspace show`]"
    else
      TERRAFORM_WORKSPACE=""
    fi
  }

  function prompt_command () {
    set_virtualenv
    set_terraform_workspace
  }

  PROMPT_COMMAND=prompt_command
fi

function ts {
  args=$@
  tmux send-keys -t right "$args" C-m
}

function sr {
  [ -f $HOME/.scratch_aliases ] && source $HOME/.scratch_aliases
}

[ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh

[ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash

export PATH=$HOME/bin:$PATH

source $HOME/.config/.bashrc

# vim: tabstop=2 shiftwidth=2 expandtab

#!/bin/bash

if [ $HOSTNAME = fruitbox ]; then
	[ -d $HOME/.qcshext ] && source $HOME/.qcshext/qcrc

	export PATH=/usr/local/sbin:$PATH
	export PATH=$HOME/.cargo/bin:$PATH
	export NOTES=$HOME/Documents/shared/notes
	export EDITOR=/usr/local/bin/vim
fi

if [ "$HOSTNAME" = piecyk ]; then
	source $HOME/.config/.profile
	source $HOME/.config/git-prompt.sh
	source $HOME/.config/git-completion.bash
	export NOTES=$HOME/documents/shared/notes

	# solarized highligthing for ls
	eval `dircolors`

	# ugly fix for bold fonts in tmux
	alias tmux='TERM=xterm-256color /usr/bin/tmux'

	export PATH=$PYENV_ROOT/bin:$PATH

	[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
	[ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"

	function set_virtualenv () {
		if [[ `pyenv version-name` == "system" ]] ; then
				PYTHON_VIRTUALENV=""
		else
				PYTHON_VIRTUALENV="(`pyenv version-name`) "
		fi
	}

	PROMPT_COMMAND=set_virtualenv
fi

[ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PATH=$HOME/bin:$PATH

source $HOME/.config/.bashrc

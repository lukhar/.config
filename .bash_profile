#!/bin/bash

[ -d $HOME/.qcshext ] && source $HOME/.qcshext/qcrc

source $HOME/.config/.bashrc
source $HOME/.config/git-prompt.sh
source $HOME/.config/git-completion.bash

[ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
[ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"

export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/bin:$PATH

if [ $HOSTNAME = fruitbox ]; then
	export PATH=/usr/local/sbin:$PATH
	export NOTES=$HOME/Documents/shared/notes
	export EDITOR=/usr/local/bin/vim
fi

if [ "$HOSTNAME" = piecyk ]; then
	export NOTES=$HOME/documents/shared/notes

	# ugly fix for bold fonts in tmux
	alias tmux='TERM=xterm-256color /usr/bin/tmux'
fi

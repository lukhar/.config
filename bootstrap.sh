#!/bin/bash

mkdir -p ~/bin
mkdir -p ~/.cache/vim/swp
mkdir -p ~/.cache/vim/undo
mkdir -p ~/sdk

ln -sf ~/.config/.agignore ~/.agignore
ln -sf ~/.config/.bashrc ~/.bashrc
ln -sf ~/.config/.bash_profile ~/.bash_profile
ln -sf ~/.config/.bash_aliases ~/.bash_aliases
ln -sf ~/.config/confupdate.sh ~/bin/confupdate
ln -sf ~/.config/.dircolors ~/.dircolors
ln -sf ~/.config/.gitignore ~/.gitignore
ln -sf ~/.config/.inputrc ~/.inputrc
ln -sf ~/.config/pentadactyl/pentadactylrc ~/.pentadactylrc
ln -sf ~/.config/.profile ~/.profile
ln -sf ~/.config/.pypirc ~/.pypirc
ln -sf ~/.config/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.config/tmux/tools/safe-reattach-to-user-namespace ~/bin/safe-reattach-to-user-namespace
ln -sf ~/.config/.vimperatorrc ~/.vimperatorrc
ln -sf ~/.config/.Xresources ~/.Xdefaults
ln -sf ~/.config/.Xresources ~/.Xresources
ln -sf ~/.config/.yaourtrc ~/.yaourtrc
ln -sf ~/.vim/gvimrc ~/.gvimrc
ln -sf ~/.vim/vimrc ~/.vimrc
ln -sf ~/.config/ctags ~/.ctags.d

if [ "$HOSTNAME" = fruitbox ]; then
  ln -sf ~/Dropbox/Shared ~/Documents/shared
fi

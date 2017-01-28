#/!bin/sh

for repository in "$HOME/.config" "$HOME/.vim"; do
	cd "${repository}" &&
	git stash &&
	git submodule foreach git pull origin master &&
	git pull origin master &&
	git stash pop
done

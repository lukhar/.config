#/!bin/sh

for repository in "$HOME/.config" "$HOME/.vim"; do
	cd "${repository}" &&

	echo "Stashing changes in: $repository"
	git stash &&
	git submodule foreach git pull origin master &&
	git pull origin master
done

[ -x "$(command -v pyenv)" ] && pyenv update
[ -x "$(command -v zinit)" ] && zinit update

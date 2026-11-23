# Link helpers shared by the home modules: `import ./links.nix { inherit config; }`.
{ config }:
rec {
  # The checkout, not the store. Everything links *out* of the store with
  # mkOutOfStoreSymlink so these stay editable in place and git-tracked -- which
  # is what bootstrap.sh does by hand, and nvim in particular needs: lazy writes
  # lazy-lock.json and harper writes the dictionary.
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";

  # The common case: the name under the target directory is the name in the
  # checkout, so the whole directory is linked under its own name.
  links =
    dir: names:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value.source = link "${dir}/${name}";
      }) names
    );
}

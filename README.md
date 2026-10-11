# dotfiles

Configuration for macOS and Arch (`piecyk`), with a NixOS laptop to come. The
checkout can live anywhere; `bootstrap.sh` resolves its own location and links
everything into place.

This repository used to *be* `$XDG_CONFIG_HOME`, which meant every application
that writes into `~/.config` showed up as untracked noise. It is now a plain
repository, and the split below is what replaced that.

## Layout

| path | what it is |
|------|------------|
| `config/` | everything that belongs in `$XDG_CONFIG_HOME`; each entry is linked to `~/.config/<name>` |
| `home/` | the handful of files that must sit in `$HOME`: bash's three, `.inputrc`, `.Xresources` |
| `bootstrap.sh` | creates those links; safe to re-run, and refuses to replace anything real |

Inside `config/`:

| path | what it is |
|------|------------|
| `shell/xdg.sh` | the single definition of the shell environment, sourced by zsh, bash and sh |
| `zsh/` | `.zshenv`, `.zprofile`, `.zshrc`, aliases, completions — reached via `ZDOTDIR` |
| `git/` | `config` and `ignore`, both read natively from `$XDG_CONFIG_HOME/git/` |
| `bin/` | scripts on `PATH`, including the tmux copy/open helpers |
| `bash/` | aliases sourced by `home/.bashrc`; bash has no XDG support of its own |
| `nvim/`, `tmux/`, `ghostty/`, `bat/`, … | per-tool config, found by XDG |
| `awesome/`, `rofi/`, `dunst/` | `piecyk` only (X11) |

## How the shell loads

`~/.zshenv` is the one symlink zsh needs. It sources `shell/xdg.sh` and exports
`ZDOTDIR`, after which zsh reads `.zprofile`, `.zshrc` and the aliases from
`zsh/` directly. Note that zsh does **not** re-read `.zshenv` from `ZDOTDIR`, so
that file runs exactly once even though it points at itself.

Because `ZDOTDIR` is set, `~/.zprofile` is never read — login-shell setup
(homebrew, pyenv, pipx, OrbStack) lives in `zsh/.zprofile` instead.

Bash has no XDG support of its own, so `.bashrc` and `.profile` source
`shell/xdg.sh` to get the same environment.

## XDG notes

`XDG_*` on its own relocates almost nothing; each tool needs its own variable,
and `shell/xdg.sh` sets them (`HISTFILE`, `LESSHISTFILE`, `PYTHON_HISTORY`,
`PSQL_HISTORY`, `NPM_CONFIG_USERCONFIG`). Tools whose config format cannot
expand variables are handled with an alias instead — see `wget` and `ag` in
`zsh/zsh_aliases`.

`XDG_RUNTIME_DIR` is deliberately never set here: `pam_systemd` provides it on
Linux and macOS has no equivalent.

Some tools find their config without help and need no symlink: tmux
(`tmux/tmux.conf`, with a literal `~/.config` fallback, so it works even when
`XDG_CONFIG_HOME` is unset), ctags (`ctags/*.ctags`), git, and vim
(`~/.vim/vimrc`).

## bootstrap.sh

Links `config/*` into `$XDG_CONFIG_HOME` and `home/*` into `$HOME`. Safe to
re-run, and it will not replace a real file or directory — on a machine that
predates this layout it reports what it left alone so you can move it first.

The `home/` files exist because these cannot be reached through XDG:

- **bash and readline** — `.bashrc`, `.bash_profile`, `.profile`, `.inputrc`
- **zsh** — `~/.zshenv`, which has to exist before `ZDOTDIR` can be set
- **`piecyk` X11** — `.Xresources`, merged by the display manager
- **Claude Code** — `~/.claude/*`, which does not honour `XDG_CONFIG_HOME`

## confupdate

`bin/confupdate` pulls this repository and `~/.vim`, then updates `pyenv` and
`zinit`. It is on `PATH` via `bin/`.

# dotfiles

Configuration for three machines:

| host | system | how it is applied |
|------|--------|-------------------|
| `fruitbox` | work Mac, nix-darwin + home-manager | `darwin-rebuild switch --flake ~/.dotfiles#fruitbox` |
| `framework` | Framework 13 laptop, NixOS + home-manager, Hyprland | `sudo nixos-rebuild switch --flake ~/.dotfiles#framework` |
| `piecyk` | Arch, no Nix | `bootstrap.sh` |

On the Nix hosts the checkout must be `~/.dotfiles`: home-manager links into
it by that path (see [Nix](#nix-fruitbox-framework)). On `piecyk` it can live
anywhere; `bootstrap.sh` resolves its own location.

This repository used to *be* `$XDG_CONFIG_HOME`, which meant every application
that writes into `~/.config` showed up as untracked noise. It is now a plain
repository, and the split below is what replaced that.

## Layout

| path | what it is |
|------|------------|
| `config/` | everything that belongs in `$XDG_CONFIG_HOME`; each entry is linked to `~/.config/<name>` |
| `home/` | the handful of files that must sit in `$HOME`: bash's three, `.inputrc`, `.Xresources` |
| `flake.nix`, `flake.lock` | the Nix hosts and their pinned inputs (nixpkgs, nix-darwin, home-manager, nixos-hardware, zen) |
| `hosts/<name>/` | one machine each: `fruitbox/`, and `framework/` with its `hardware-configuration.nix` and `home.nix` |
| `modules/` | shared Nix modules: `home/` (home-manager, both hosts), `nixos/desktop.nix`, `darwin/homebrew.nix` |
| `bootstrap.sh` | creates the links on `piecyk`; safe to re-run, and refuses to replace anything real |

Inside `config/`:

| path | what it is |
|------|------------|
| `shell/xdg.sh` | the single definition of the shell environment, sourced by zsh, bash and sh |
| `zsh/` | `.zshenv`, `.zprofile`, `.zshrc`, aliases, completions — reached via `ZDOTDIR` |
| `git/` | `config` and `ignore`, both read natively from `$XDG_CONFIG_HOME/git/` |
| `bin/` | scripts on `PATH`, including the tmux copy/open helpers |
| `bash/` | aliases sourced by `home/.bashrc`; bash has no XDG support of its own |
| `nvim/`, `tmux/`, `ghostty/`, `bat/`, … | per-tool config, found by XDG |
| `alacritty/` | shared; font size per host via imports (`font-size.toml`, `framework.toml`) |
| `rofi/` | shared; `framework` adds `solarized.rasi` as its theme |
| `hypr/`, `waybar/`, `mako/`, `gtk/`, `zen/`, `networkmanager-dmenu/` | `framework` only (Wayland, solarized dark) |
| `awesome/`, `dunst/` | `piecyk` only (X11) |

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

## Nix (fruitbox, framework)

`flake.nix` defines both hosts. Each imports `modules/home` for home-manager
plus whatever the host adds on top (`hosts/framework/home.nix`).

home-manager links `config/*` and `home/*` with `mkOutOfStoreSymlink`, i.e. to
the files in this checkout rather than copies in the Nix store. So:

- editing anything under `config/` takes effect at once — no rebuild;
- only `.nix` changes need a rebuild;
- a **new** file has to be `git add`ed before a rebuild, or the flake can't see it.

On `framework`:

```sh
nixos-rebuild build --flake ~/.dotfiles#framework            # check only
sudo nixos-rebuild switch --flake ~/.dotfiles#framework      # apply now
sudo nixos-rebuild boot --flake ~/.dotfiles#framework        # apply at next boot (kernel, greetd)
sudo nixos-rebuild switch --rollback                         # back to the previous generation
nix flake update --flake ~/.dotfiles                         # newer inputs; then rebuild, commit flake.lock
nix fmt                                                      # format every .nix file
```

Older generations are also in the systemd-boot menu; garbage collection keeps
14 days of them.

`fruitbox` uses Determinate Nix, so nix-darwin leaves the daemon and
`/etc/nix` alone (`nix.enable = false`). Homebrew remains its package manager:
`modules/darwin/homebrew.nix` declares the formulae and casks, applied by
`brew bundle` on activation, without cleanup or upgrades.

### framework

| file | what it is |
|------|------------|
| `hosts/framework/default.nix` | the machine: boot, network, user, hardware, power, Nix settings |
| `hosts/framework/home.nix` | its home-manager: CLI tools, GTK look, the Wayland config links |
| `modules/nixos/desktop.nix` | the desktop: Hyprland (uwsm), autologin, lock/idle, waybar, mako, thunar |

Logging in: greetd logs straight into the uwsm-managed Hyprland, which starts
locked (`--locked-cmd hyprlock`): the password goes into the lock screen, and
the session's services (waybar, mako, hypridle, the polkit agent) are already
up behind it. After logging out (Super+M) greetd shows a text login that starts
the same session; another one is on Ctrl+Alt+F2.

Sleep: closing the lid on battery suspends, then hibernates after 2 hours into
the swap partition; on AC it only suspends; with an external monitor it does
nothing. 15 idle minutes do the same; Super+L locks.

## bootstrap.sh

For `piecyk`, which has no Nix. Links `config/*` into `$XDG_CONFIG_HOME` and
`home/*` into `$HOME`. Safe to re-run, and it will not replace a real file or
directory — on a machine that predates this layout it reports what it left
alone so you can move it first.

The `home/` files exist because these cannot be reached through XDG:

- **bash and readline** — `.bashrc`, `.bash_profile`, `.profile`, `.inputrc`
- **zsh** — `~/.zshenv`, which has to exist before `ZDOTDIR` can be set
- **`piecyk` X11** — `.Xresources`, merged by the display manager
- **Claude Code** — `~/.claude/*`, which does not honour `XDG_CONFIG_HOME`

## confupdate

`bin/confupdate` pulls this repository and `~/.vim`, then updates `pyenv` and
`zinit`. It is on `PATH` via `bin/`.

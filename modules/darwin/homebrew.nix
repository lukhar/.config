{
  # Homebrew stays the package manager for this Mac; nix-darwin only declares
  # what should be installed, by writing a Brewfile and running brew bundle on
  # activation. It does not install Homebrew itself.
  homebrew = {
    enable = true;

    onActivation = {
      # "zap" would uninstall anything not listed below, and this list was
      # generated from `brew leaves` -- which omits dependencies pulled in by
      # other formulae. Leave it at "none" until the list has been lived with.
      cleanup = "none";

      # Switching a system should not also upgrade 112 packages as a side
      # effect; run `brew upgrade` deliberately instead.
      autoUpdate = false;
      upgrade = false;
    };

    taps = [
    "aquasecurity/trivy"
    "coursier/formulas"
    "gromgit/fuse"
    "hashicorp/tap"
    "mistertea/et"
    "sourcegraph/src-cli"
    "turbot/tap"
    "universal-ctags/universal-ctags"
    ];

    # From `brew leaves`: explicitly installed, dependencies excluded.
    brews = [
    "automake"
    "bat"
    "bats-core"
    "cmake"
    "colima"
    "cookiecutter"
    "curl"
    "ddgr"
    "dive"
    "docker"
    "exiftool"
    "fd"
    "fzf"
    "gawk"
    "gcc"
    "gh"
    "ghostscript"
    "gifsicle"
    "gifski"
    "git"
    "git-filter-repo"
    "glances"
    "gnupg"
    "goenv"
    "helm"
    "htop"
    "hub"
    "img2pdf"
    "iproute2mac"
    "ivy"
    "jfrog-cli"
    "jq"
    "k3d"
    "k9s"
    "kind"
    "kubernetes-cli"
    "libmetalink"
    "libvterm"
    "llvm"
    "logcli"
    "luarocks"
    "mosh"
    "neofetch"
    "neovide"
    "nghttp2"
    "ninja"
    "nmap"
    "node"
    "nvm"
    "ollama"
    "openconnect"
    "pipx"
    "postgresql@14"
    "pssh"
    "pyenv-virtualenv"
    "pyinvoke"
    "python@3.9"
    "rbenv"
    "ripgrep"
    "rustup"
    "stylua"
    "subversion"
    "tcl-tk"
    "tfenv"
    "tmux"
    "tree"
    "tree-sitter-cli"
    "unar"
    "universal-ctags"
    "unzip"
    "uv"
    "vim"
    "watch"
    "watchman"
    "wget"
    "yarn"
    "zlib"
    ];

    casks = [
    "alacritty"
    "amethyst"
    "asana"
    "basictex"
    "claude"
    "cursor"
    "darktable"
    "dropbox"
    "firefox"
    "font-dejavu"
    "font-dejavu-sans-mono-nerd-font"
    "font-droid-sans-mono-for-powerline"
    "font-droid-sans-mono-nerd-font"
    "font-fira-code"
    "font-fira-mono-for-powerline"
    "font-jetbrains-mono"
    "font-jetbrains-mono-nerd-font"
    "font-liberation-nerd-font"
    "ghostty"
    "grammarly-desktop"
    "iterm2"
    "jetbrains-toolbox"
    "macfuse"
    "microsoft-auto-update"
    "microsoft-teams"
    "postman"
    "qutebrowser"
    "signal"
    "skim"
    "spotify"
    "steam"
    "vagrant"
    "viber"
    "visual-studio-code"
    "zen"
    ];
  };
}

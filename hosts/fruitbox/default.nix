{
  imports = [ ../../modules/darwin/homebrew.nix ];

  # The work Mac. Apple Silicon, Jamf-managed -- which is why the hostname is an
  # asset tag and this host is selected by flake attribute instead.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Nix installed and manages the daemon, store and nix.conf itself.
  # Letting nix-darwin manage nix as well makes the two fight over /etc/nix.
  nix.enable = false;

  system.stateVersion = 6;
  system.primaryUser = "lharatym";

  users.users.lharatym = {
    name = "lharatym";
    home = "/Users/lharatym";
  };

  # Makes nix-darwin manage /etc/zshrc so the nix profile reaches login shells.
  # The actual zsh configuration stays in config/zsh, reached through ZDOTDIR.
  programs.zsh.enable = true;

  # nix-darwin's /etc/zshrc otherwise runs a bare `compinit`, which dumps to
  # $ZDOTDIR/.zcompdump -- inside this repository -- and means compinit runs
  # twice per shell. config/zsh/.zshrc already calls it via zinit with an
  # explicit -d under XDG_CACHE_HOME.
  programs.zsh.enableCompletion = false;
  programs.zsh.enableBashCompletion = false;
}

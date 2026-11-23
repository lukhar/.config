{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # Framework 13, Core Ultra X7 358H (Panther Lake)
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Keep the boot menu short; older generations stay rollback-able until gc'd.
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "framework";
  # Wi-Fi: nmtui (Super+W) or nmcli.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # The text console takes its layout from xkb: pl, caps lock as escape.
  # Hyprland has its own kb_layout/kb_options in hyprland.lua.
  services.xserver.xkb.layout = "pl";
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # Sound. hyprland.lua's volume keys call wpctl, which comes with wireplumber.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.lukhar = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  # config/zsh/.zshrc runs compinit itself, via zinit.
  programs.zsh.enableCompletion = false;
  programs.zsh.enableBashCompletion = false;

  # Also enables xdg portals, with the hyprland and gtk ones.
  programs.hyprland.enable = true;
  # Run hyprland as a systemd user session (uwsm): graphical-session.target,
  # so idle, the bar, notifications and the polkit agent start as services.
  # config/zsh/.zprofile starts it on tty1.
  programs.hyprland.withUWSM = true;
  # Lock and idle; configs in config/hypr/hyprlock.conf and hypridle.conf.
  # The hyprlock module also adds the PAM service it authenticates against.
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  # Polkit agent: the password prompt when a GUI app asks for privileges
  # (mounting in thunar, ...). The package ships the user unit; NixOS ignores
  # [Install], so it is hooked to the session here.
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

  # The desktop itself and what root needs. Everything else is per-user, in
  # modules/home (home.packages).
  environment.systemPackages = with pkgs; [
    git

    # called by hyprland.lua: launcher, file manager, media/brightness keys
    hyprlauncher
    thunar
    brightnessctl
    playerctl
    # config/bin/tmux-copy falls back to wl-copy on wayland
    wl-clipboard
    # not in nixpkgs; from the zen-browser flake input (command: zen-beta)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # config/fontconfig/fonts.conf and qutebrowser ask for Liberation;
  # alacritty and ghostty ask for "DejaVuSansM Nerd Font Mono".
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.dejavu-sans-mono
  ];

  # Unfree packages are allowed by name, not wholesale.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  # mason downloads prebuilt linux binaries (lua_ls, harper_ls, stylua, ...)
  # that expect /lib64/ld-linux-x86-64.so.2; nix-ld provides it on NixOS.
  programs.nix-ld.enable = true;

  # config/systemd/user/ssh-agent.service hardcodes /usr/bin/ssh-agent (Arch);
  # NixOS runs its own user agent instead.
  programs.ssh.startAgent = true;

  # Laptop hardware. nixos-hardware's framework module (imported above) already
  # covers fwupd, fprintd, the light sensor, the EC kernel module and a new
  # enough kernel; these are what it leaves out.
  #
  # power-profiles-daemon is what Framework recommends; enabling it also keeps
  # nixos-hardware from falling back to TLP.
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  hardware.bluetooth.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Flakes only. NIX_PATH and the registry still point nixpkgs at this flake's
  # nixpkgs, so nix-shell -p and nix run nixpkgs#... keep working.
  nix.channel.enable = false;
  # keep nix's user profile/channels under ~/.local/state, not ~/.nix-profile
  nix.settings.use-xdg-base-directories = true;
  # hard-link identical files in the store to save disk
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # The NixOS release this machine was installed with. Never change it:
  # it is not the nixpkgs version, it pins defaults for stateful data.
  system.stateVersion = "26.05";
}

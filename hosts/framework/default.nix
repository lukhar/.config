# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pl";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "pl";
  services.xserver.xkb.options = "caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Sound. hyprland.lua's volume keys call wpctl, which comes with wireplumber.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lukhar = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input"];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;
  programs.zsh.enableBashCompletion = false;

  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [ 
    git
    neovim
    tmux
    fzf
    ripgrep
    fd
    bat
    alacritty
    wget
    kitty
    pyenv
    fnm

    # called by hyprland.lua: launcher, file manager, media/brightness keys
    hyprlauncher
    thunar
    brightnessctl
    playerctl
    # config/bin/tmux-copy falls back to wl-copy on wayland
    wl-clipboard
    # configs already linked by modules/home
    qutebrowser
    zathura
  ];

  # config/fontconfig/fonts.conf and qutebrowser ask for Liberation;
  # alacritty and ghostty ask for "DejaVuSansM Nerd Font Mono".
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.dejavu-sans-mono
  ];

  # config/systemd/user/ssh-agent.service hardcodes /usr/bin/ssh-agent (Arch);
  # NixOS runs its own user agent instead.
  programs.ssh.startAgent = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Laptop hardware. nixos-hardware's framework module (flake.nix) already
  # covers fwupd, fprintd, the light sensor, the EC kernel module and a new
  # enough kernel; these are what it leaves out.
  #
  # power-profiles-daemon is what Framework recommends; enabling it also keeps
  # nixos-hardware from falling back to TLP.
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  hardware.bluetooth.enable = true;

  # Keep the boot menu short; older generations stay rollback-able until gc'd.
  boot.loader.systemd-boot.configurationLimit = 10;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  # hard-link identical files in the store to save disk
  nix.settings.auto-optimise-store = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine, # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}


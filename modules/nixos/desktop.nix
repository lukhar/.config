# The Hyprland desktop: session, its services, the apps hyprland.lua calls,
# sound and fonts. Configs live in config/ (hypr, waybar, mako, rofi, ...),
# linked by hosts/framework/home.nix.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Sound. hyprland.lua's volume keys call wpctl, which comes with wireplumber.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Also enables xdg portals, with the hyprland and gtk ones.
  programs.hyprland.enable = true;
  # Run hyprland as a systemd user session (uwsm): graphical-session.target,
  # so idle, the bar, notifications and the polkit agent start as services.
  # greetd below starts it.
  programs.hyprland.withUWSM = true;

  # Login: greetd logs straight into the uwsm session, and hyprland starts
  # locked (--locked-cmd: hyprlock is up before anything is drawn), so the
  # password goes into the usual lock screen and boot never hands over between
  # compositors. After logging out (Super+M) greetd falls back to agreety, its
  # plain text login, which starts the same session.
  services.greetd = {
    enable = true;
    settings =
      let
        uwsm = "${config.programs.uwsm.package}/bin/uwsm";
        hyprland = "${uwsm} start -e -D Hyprland -- hyprland.desktop";
      in
      {
        initial_session = {
          user = "lukhar";
          command = "${hyprland} -- --locked-cmd ${config.programs.hyprlock.package}/bin/hyprlock";
        };
        default_session.command = "${pkgs.greetd}/bin/agreety --cmd '${hyprland}'";
      };
  };

  # Lock and idle; configs in config/hypr/hyprlock.conf and hypridle.conf.
  # The hyprlock module also adds the PAM service it authenticates against.
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  # Bar, as a user service with the session; config in config/waybar.
  programs.waybar.enable = true;
  # waybar's unit reloads with a bare `kill`, which user units can't find on
  # NixOS; "" clears it before the full path replaces it (SIGUSR2 = reload)
  systemd.user.services.waybar.serviceConfig.ExecReload = [
    ""
    "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID"
  ];
  # Defining the unit here gives it NixOS's minimal default PATH (coreutils,
  # grep, sed, systemd), so on-click commands (networkmanager_dmenu, wpctl)
  # weren't found. Give it the session's PATH instead; %u is the user.
  systemd.user.services.waybar.environment.PATH =
    lib.mkForce "/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
  # File manager (Super+E). gvfs: trash, mounting from the sidebar, network
  # places; tumbler: thumbnails; udisks2 (already on) does the mounting.
  # The archive plugin hands extract/compress to xarchiver.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  # No NixOS module for these two; their packages ship user units, and NixOS
  # ignores [Install], so they are hooked to the session here.
  # - hyprpolkitagent: the password prompt when a GUI app asks for privileges
  #   (mounting in thunar, ...)
  # - mako: notifications, config in config/mako. Its D-Bus activation file
  #   too, so a notification starts it if it isn't running.
  systemd.packages = with pkgs; [
    hyprpolkitagent
    mako
  ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];
  systemd.user.services.mako.wantedBy = [ "graphical-session.target" ];
  services.dbus.packages = [ pkgs.mako ];

  environment.systemPackages = with pkgs; [
    # called by hyprland.lua: launcher, media/brightness keys,
    # makoctl for the notification keys
    rofi
    mako
    brightnessctl
    # thunar-archive-plugin's backend
    xarchiver
    playerctl
    # Wi-Fi menu in rofi (Super+W, waybar's network module); its "edit
    # connections" entry opens nmtui in alacritty. No networkmanagerapplet:
    # its tray icon autostarts and duplicates waybar's network module.
    networkmanager_dmenu
    # config/bin/tmux-copy falls back to wl-copy on wayland
    wl-clipboard
    # config/bin/screenshot: capture, region select, notification
    grim
    slurp
    libnotify
    # not in nixpkgs; from the zen-browser flake input (command: zen-beta)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # config/fontconfig/fonts.conf and qutebrowser ask for Liberation;
  # alacritty and ghostty ask for "DejaVuSansM Nerd Font Mono".
  fonts.packages = with pkgs; [
    liberation_ttf
    nerd-fonts.dejavu-sans-mono
  ];
}

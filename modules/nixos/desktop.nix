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
  # The login screen below starts it: pick "Hyprland (uwsm-managed)" once,
  # ReGreet remembers it.
  programs.hyprland.withUWSM = true;

  # Login screen: ReGreet (GTK4) on greetd, solarized via
  # config/regreet/solarized.css. It runs inside a minimal hyprland rather than
  # the module's default cage: cage can't scale, and at 1x the 2880x1920 panel
  # makes it unreadably small. Through start-hyprland, the watchdog wrapper:
  # bare Hyprland warns on screen. Text login stays on Ctrl+Alt+F2.
  services.displayManager.regreet = {
    enable = true;
    font = {
      name = "DejaVuSansM Nerd Font Mono";
      package = pkgs.nerd-fonts.dejavu-sans-mono;
      # 10pt as in gtk and alacritty; the greeter's hyprland scales it by 2
      size = 10;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "darkcyan"; };
    };
    extraCss = ../../config/regreet/solarized.css;
    settings = {
      GTK.application_prefer_dark_theme = true;
      widget.clock.format = "%a %d %b  %H:%M";
    };
  };
  services.greetd.settings.default_session.command =
    "${pkgs.dbus}/bin/dbus-run-session ${config.programs.hyprland.package}/bin/start-hyprland -- --config /etc/greetd/hyprland.lua";
  environment.etc."greetd/hyprland.lua".text = ''
    -- The login screen's compositor (greetd -> this -> regreet), not the desktop.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
    -- GTK4's default vulkan renderer flickers on this Panther Lake (xe) GPU
    hl.env("GSK_RENDERER", "ngl")
    hl.config({
      animations = { enabled = false },
      input = { kb_layout = "pl", kb_options = "caps:escape" },
      misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = "rgb(002b36)",
      },
    })
    hl.on("hyprland.start", function()
      hl.exec_cmd("${lib.getExe config.services.displayManager.regreet.package}; ${config.programs.hyprland.package}/bin/hyprctl dispatch 'hl.dsp.exit()'")
    end)
  '';

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

  # These are global user units on graphical-session.target, and the login
  # screen's hyprland (user greeter) reaches that target too: without this,
  # the greeter ran its own bar, idle daemon, notifications and polkit agent.
  # !@system: only for real users, not system accounts like greeter.
  systemd.user.services.waybar.unitConfig.ConditionUser = "!@system";
  systemd.user.services.hypridle.unitConfig.ConditionUser = "!@system";
  systemd.user.services.mako.unitConfig.ConditionUser = "!@system";
  systemd.user.services.hyprpolkitagent.unitConfig.ConditionUser = "!@system";

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
    # connections" entry opens nm-connection-editor from networkmanagerapplet
    networkmanager_dmenu
    networkmanagerapplet
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

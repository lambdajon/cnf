{ pkgs, hostname, username, ... }: {
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "nvidia.NVreg_RegistryDwords=EnableBrightnessControl=1"
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.swraid.enable = false;

  networking.hostName = hostname;

  networking.networkmanager.enable = true;

  time.timeZone = "Etc/GMT-5";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_US";
    LC_ALL = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,ru";
      options = "caps:escape,grp:alt_shift_toggle";
      variant = "altgr-intl";
    };
    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
    };
    desktopManager = {
      gnome.enable = true;

      extraGSettingsOverrides = ''
            # Change default background
            [org.gnome.desktop.background]
            picture-uri='file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}'

            # Background for dark theme
            [org.gnome.desktop.background]
            picture-uri-dark='file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}'

            # Prefer dark theme
            [org.gnome.desktop.interface]
            color-scheme='prefer-dark'

            # Favorite apps in gnome-shell
            [org.gnome.shell]
            favorite-apps=['org.gnome.Nautilus.desktop', 'org.gnome.Epiphany.desktop', 'org.gnome.SystemMonitor.desktop', 'Alacritty.desktop']

            # Enable user extensions
            [org.gnome.shell]
            disable-user-extensions=false

            # List of enabled extensions
            [org.gnome.shell]
            enabled-extensions=['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'appindicatorsupport@rgcjonas.gmail.com', 'gsconnect@andyholmes.github.io']

            # ID of GSConnect device
            [org.gnome.shell.extensions.gsconnect]
            id='5fe9c449-c81e-4ca0-bc20-2dfc2b353228'

            # Name of GSConnect device
            [org.gnome.shell.extensions.gsconnect]
            name='Kolyma'

            # Workspace should grow dynamically
            [org.gnome.mutter]
            dynamic-workspaces=true

            # Edge Tiling with mouse
            [org.gnome.mutter]
            edge-tiling=true

            # Set the icon theme
            [org.gnome.desktop.interface]
            icon-theme='Papirus-Dark'

            # Never show the notice on tweak
            [org.gnome.tweaks]
            show-extensions-notice=false

            # Show all three button layers
            [org.gnome.desktop.wm.preferences]
            button-layout='appmenu:minimize,maximize,close'

            # Shitty monospace font to JetBrains Mono
            [org.gnome.desktop.interface]
            monospace-font-name='JetBrainsMono Nerd Font 10'

            # Don't hibernate on delay
            [org.gnome.settings-daemon.plugins.power]
            sleep-inactive-ac-type='nothing'

            # Don't sleep, don't sleep!
            [org.gnome.desktop.session]
            idle-delay=0
          '';
    };
    videoDrivers = [ "nvidia" ];
  };

  hardware.opengl = all-opengl // x86_64-opengl;

  services.openssh.enable = true;
  services.pcscd.enable = true;
  services.printing.enable = true;
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 5;
  services.thermald.enable = true;

  services.redis.servers."global".enable = true;
  services.redis.servers."global".port = 6379;
  services.redis.vmOverCommit = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  virtualisation.docker.enable = true;
  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    docker-compose
    file
    vim
    wget
    gnumake
    xclip
    lsof
    strace
    zip
    unzip
    fdupes
    libGL
    pulseaudio
    
  ];
  environment.gnome.excludePackages = (with pkgs; [
    gnome.dconf-editor
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    papirus-icon-theme
    gnome-photos
    gnome-tour
    gedit
    cheese
    gnome-music
    gnome-console
    gnome-terminal
    epiphany
    geary
    evince
    totem
    tali
    iagno
    hitori
    atomix
    seahorse
    
  ]);
  environment.variables = {
    LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${pkgs.libGL}/lib";
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk
      iosevka-bin
      julia-mono
      apple-fonts.sf-pro
      apple-fonts.sf-mono
      apple-fonts.ny
    ];
    fontconfig = {
      enable = true;
      localConf = builtins.readFile ../../.config/fontconfig/fonts.conf;
    };
  };


  programs.zsh.enable = true;
  programs.ssh.extraConfig = ''
    Host *
    ServerAliveInterval 120
  '';
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  hardware.graphics = {
    enable = true;
  };
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
  };
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
  

  system.stateVersion = "24.05";
}

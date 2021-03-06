{ config, pkgs, options, ... }:

let
  theme = (import ../../config/theme.nix);
in
{
  boot = {
    kernelPackages = pkgs.head.linuxPackages_latest;
    kernelParams = [
      "rw"
      "mitigations=off"
      "acpi_backlight=vendor"
      "nmi_watchdog=0"
      "systemd.watchdog-device=/dev/watchdog"
      "vt.default_red=0x16,0xe9,0x29,0xfa,0x26,0xee,0x59,0xfd,0x23,0xec,0x3f,0xfb,0x3f,0xf0,0x6b,0xfd"
      "vt.default_grn=0x16,0x56,0xd3,0xb7,0xbb,0x64,0xe3,0xf0,0x35,0x6a,0xda,0xc3,0xc6,0x75,0xe6,0xf0"
      "vt.default_blu=0x1c,0x78,0x98,0x95,0xd9,0xae,0xe3,0xed,0x30,0x88,0xa4,0xa7,0xde,0xb7,0xe6,0xed"
    ];
    kernel.sysctl = {
      "vm.swappiness" = 1;
      "vm.vfs_cache_pressure" = 75;
      "kernel.printk" = "3 3 3 3";
      "kernel.unprivileged_userns_clone" = 1;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        gfxmodeEfi = "1366x768";
      };
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  hardware = {
    bluetooth = {
      enable = true;
      hsphfpd.enable = true;
      package = pkgs.bluezFull;
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
    };
  };
  imports = [ ./hardware-configuration.nix ];
  i18n.defaultLocale = "en_US.UTF-8";
  environment = {
    pathsToLink = [ "/share/zsh" ];
    sessionVariables = with pkgs; {
      "LD_PRELOAD" = "/etc/nixos/config/ld-preload-xcreatewindow.so";
      "XSECURELOCK_BLANK_TIMEOUT" = "5";
      "XSECURELOCK_BLANK_DPMS_STATE" = "suspend";
      "XSECURELOCK_KEY_XF86AudioPlay_COMMAND" = "${playerctl}/bin/playerctl play-pause";
      "XSECURELOCK_KEY_XF86AudioPrev_COMMAND" = "${playerctl}/bin/playerctl previous";
      "XSECURELOCK_KEY_XF86AudioNext_COMMAND" = "${playerctl}/bin/playerctl next";
      "XSECURELOCK_KEY_XF86AudioMute_COMMAND" = "/etc/nixos/scripts/volume toggle";
      "XSECURELOCK_KEY_XF86AudioRaiseVolume_COMMAND" = "/etc/nixos/scripts/volume up";
      "XSECURELOCK_KEY_XF86AudioLowerVolume_COMMAND" = "/etc/nixos/scripts/volume down";
      "XSECURELOCK_KEY_XF86MonBrightnessUp_COMMAND" = "${brightnessctl}/bin/brightnessctl s +10%";
      "XSECURELOCK_KEY_XF86MonBrightnessDown_COMMAND" = "${brightnessctl}/bin/brightnessctl s 10%-";
    };
    systemPackages = with pkgs; [
      adoptopenjdk-openj9-bin-15
      alsaTools
      alsaUtils
      brightnessctl
      ccls
      cmake
      coreutils
      curl
      dash
      dragon-drop
      elixir
      envsubst
      fd
      file
      ffmpeg
      font-manager
      gcc
      ghc
      git
      glxinfo
      gnumake
      go
      gradle
      gxmessage
      hacksaw
      head.haskell-language-server
      hsetroot
      imagemagick
      jp2a
      jq
      libtool
      libva-utils
      nixfmt
      nixpkgs-review
      nodePackages.npm
      nodePackages.typescript
      nodejs
      notify-desktop
      ntfs3g
      nur.repos.fortuneteller2k.abstractdark-sddm-theme
      pandoc
      pavucontrol
      pciutils
      pcmanfm
      psmisc
      pulseaudio
      python3
      python39Packages.grip
      ripgrep
      rust-analyzer-unwrapped
      rustup
      shellcheck
      shotgun
      stack
      unrar
      unzip
      util-linux
      wget
      xarchiver
      xclip
      xdo
      xdotool
      xidlehook
      xmonad-log
      xorg.xdpyinfo
      xorg.xsetroot
      xorg.xkill
      xorg.xwininfo
      xsecurelock
      xwallpaper
      zig
      zip
    ];
  };
  fonts = {
    fonts = with pkgs; [
      cozette
      emacs-all-the-icons-fonts
      fantasque-sans-mono
      input-fonts
      inter
      iosevka-ft
      mplus-outline-fonts
      nerdfonts
      output-fonts
      sarasa-gothic
      scientifica
      symbola
      twemoji-color-font
      xorg.fontbh100dpi
    ];
    fontconfig = {
      enable = true;
      dpi = 96;
      defaultFonts = {
        serif = [ "Sarasa Gothic J" ];
        sansSerif = [ "Sarasa Gothic J" ];
        monospace = [
          "Iosevka FT"
          "Iosevka Nerd Font"
          "Sarasa Mono J"
        ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
  networking = {
    hostName = "superfluous";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      dns = "none";
    };
    useDHCP = false;
    interfaces = {
      eno1.useDHCP = true;
      wlo1.useDHCP = true;
    };
  };
  powerManagement.cpuFreqGovernor = "performance";
  programs = {
    bash = {
      promptInit = ''eval "$(${pkgs.starship}/bin/starship init bash)"'';
      interactiveShellInit = ''export HISTFILE=$HOME/.config/.bash_history'';
    };
    command-not-found.enable = false;
    qt5ct.enable = true;
    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.xsecurelock}/bin/xsecurelock";
    };
  };
  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false;
    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
  services = {
    blueman.enable = true;
    chrony = {
      enable = true;
      servers = [
        "ntp.pagasa.dost.gov.ph"
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };
    dbus.packages = with pkgs; [ gnome3.dconf ];
    irqbalance.enable = true;
    openssh = {
      enable = true;
      gatewayPorts = "yes";
      permitRootLogin = "yes";
    };
    picom = {
      enable = true;
      refreshRate = 60;
      backend = "glx";
      vSync = true;
    };
    pipewire = {
      enable = true;
      socketActivation = false;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    tlp.enable = true;
    upower.enable = true;
    xserver = {
      enable = true;
      dpi = 96;
      config = (import ../../config/xorg-amd-tearfree.nix);
      displayManager = {
        sddm = {
          enable = true;
          theme = "abstractdark-sddm-theme";
        };
        defaultSession = "none+${theme.wm}";
      };
      useGlamor = true;
      windowManager = {
        awesome = {
          enable = if theme.wm == "awesome" then true else false;
          luaModules = with pkgs.luaPackages; [ luarocks ];
        };
        xmonad = {
          enable = if theme.wm == "xmonad" then true else false;
          config = (import ../../config/xmonad.nix { inherit config pkgs theme; });
          extraPackages = hpkgs: with hpkgs; [ dbus xmonad-contrib ];
          ghcArgs = [
            "-O2"
            "-funfolding-use-threshold=16"
            "-fexcess-precision"
            "-optc-O3"
            "-optc-ffast-math"
          ];
          haskellPackages =
            let owner = "xmonad";
            in
            pkgs.haskellPackages.extend (pkgs.haskell.lib.packageSourceOverrides {
              xmonad = pkgs.fetchFromGitHub {
                inherit owner;
                repo = owner;
                rev = "a90558c07e3108ec2304cac40e5d66f74f52b803";
                sha256 = "sha256-+TDKhCVvxoRLzHZGzFnClFqKcr4tUrwFY1at3Rwllus=";
              };
              xmonad-contrib = pkgs.fetchFromGitHub {
                inherit owner;
                repo = "${owner}-contrib";
                rev = "8a0151fe77fecaa1e3b3566e6b05f7479687ecb8";
                sha256 = "sha256-+p/oznVfM/ici9wvpmRp59+W+yZEPShpPkipjOhiguU=";
              };
            });
        };
      };
      layout = "us";
      libinput = {
        enable = true;
        mouse.accelProfile = "flat";
        touchpad.naturalScrolling = true;
      };
    };
  };
  system = {
    userActivationScripts = {
      reloadWallpaper.text = ''
        if [ $DISPLAY ]; then
          ${pkgs.xwallpaper}/bin/xwallpaper --zoom ${theme.wallpaper}
        else
          ${pkgs.coreutils}/bin/echo "skipping..."
        fi
      '';
      reloadXMonad.text = if theme.wm != "xmonad" then "echo 'skipping...'" else ''
        if [ $DISPLAY ]; then
          ${pkgs.xmonad-with-packages}/bin/xmonad --restart
        else
          ${pkgs.coreutils}/bin/echo "skipping..."
        fi
      '';
    };
    stateVersion = "21.05";
  };
  systemd = {
    extraConfig = "RebootWatchdogSec=5";
    services.rtkit-daemon.serviceConfig.ExecStart = [
      ""
      "${pkgs.rtkit}/libexec/rtkit-daemon --our-realtime-priority=95 --max-realtime-priority=90"
    ];
    user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
  time.timeZone = "Asia/Manila";
  users.users.fortuneteller2k = {
    isNormalUser = true;
    home = "/home/fortuneteller2k";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "realtime"
      "realtime"
    ];
  };
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}

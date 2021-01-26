{ config, pkgs, options, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  nix.package = pkgs.nixFlakes;
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "rw"
      "mitigations=off"
      "acpi_backlight=vendor"
      "vt.default_red=0x16,0xe9,0x29,0xfa,0x26,0xee,0x59,0xfd,0x23,0xec,0x3f,0xfb,0x3f,0xf0,0x6b,0xfd"
      "vt.default_grn=0x16,0x56,0xd3,0xb7,0xbb,0x64,0xe3,0xf0,0x35,0x6a,0xda,0xc3,0xc6,0x75,0xe6,0xf0"
      "vt.default_blu=0x1c,0x78,0x98,0x95,0xd9,0xae,0xe3,0xed,0x30,0x88,0xa4,0xa7,0xde,0xb7,0xe6,0xed"
    ];
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
  zramSwap.enable = true;
  time.timeZone = "Asia/Manila";
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
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  services = {
    dbus.packages = with pkgs; [ gnome3.dconf ];
    xserver = {
      enable = true;
      dpi = 96;
      config = (import ./config/xorg-amd-tearfree.nix);
      displayManager = {
        lightdm = {
          enable = true;
          background = ./config/wallpapers/horizon.jpg;
          greeters.gtk = {
            enable = true;
            iconTheme = {
              name = "Papirus";
              package = pkgs.papirus-icon-theme;
            };
            theme = {
              name = "fortuneteller2k_phocus";
              package = pkgs.phocus;
            };
          };
        };
        defaultSession = "none+xmonad";
      };
      windowManager = {
        xmonad = {
          enable = true;
          config = (import ./config/xmonad.nix);
          extraPackages = hpkgs: with hpkgs; [ dbus monad-logger xmonad-contrib ];
          haskellPackages = pkgs.haskellPackages.extend (pkgs.haskell.lib.packageSourceOverrides {
            xmonad = pkgs.fetchFromGitHub {
              owner = "xmonad";
              repo = "xmonad";
              rev = "56b0f850bc35200ec23f05c079eca8b0a1f90305";
              sha256 = "sha256-vy9DE2id7sfnEKCHbl6IFOKibya8jWSD6DbX1vBJOwY";
            };
            xmonad-contrib = pkgs.fetchFromGitHub {
              owner = "xmonad";
              repo = "xmonad-contrib";
              rev = "b8ac9804fce2db643faa19c909e6560f7e65944b";
              sha256 = "sha256-Q1RhbiCWNEiWJAvf7eWcmUVXjy6cioHRGFwVZEHRvpA=";
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
    openssh.enable = true;
  };
  systemd.user.services = {
    pipewire.wantedBy = [ "default.target" ];
    pipewire-pulse.wantedBy = [ "default.target" ];
  };
  sound.enable = true;
  hardware = {
    pulseaudio.enable = pkgs.lib.mkForce false;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
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
  users.users.fortuneteller2k = {
    isNormalUser = true;
    home = "/home/fortuneteller2k";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };
  environment.systemPackages = with pkgs; [
    brightnessctl
    ccls
    cmake
    copyq
    coreutils
    curl
    dragon-drop
    elixir
    envsubst
    fd
    ffmpeg
    font-manager
    gcc
    ghc
    git
    gnumake
    go
    hacksaw
    haskell-language-server
    i3lock-fancy-rapid
    imagemagick
    jp2a
    jq
    libsForQt514.qtstyleplugins
    libtool
    nixfmt
    nodePackages.npm
    nodePackages.typescript
    nodejs
    notify-desktop
    ntfs3g
    pandoc
    pcmanfm
    pulseaudio
    python3
    python39Packages.grip
    ripgrep
    rust-analyzer-unwrapped
    rustup
    shellcheck
    shotgun
    slock
    stack
    unzip
    wget
    xarchiver
    xclip
    xdo
    xdotool
    xidlehook
    xmonad-log
    xorg.xdpyinfo
    xorg.xkill
    xorg.xwininfo
    xwallpaper
    zig
    zip
  ];
  programs = {
    qt5ct.enable = true;
    slock.enable = true;
    xss-lock = {
      enable = true;
      lockerCommand = "${pkgs.slock}/bin/slock";
    };
    bash = {
      promptInit = ''eval "$(${pkgs.starship}/bin/starship init bash)"'';
      interactiveShellInit = "export HISTFILE=$HOME/.config/.bash_history";
    };
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      promptInit = "eval $(starship init zsh)";
      interactiveShellInit = (import ./config/zshrc.nix);
      shellAliases = (import ./config/zsh-aliases.nix);
    };
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        swaybg
        wl-clipboard
        mako
        grim
        slurp
        sway-contrib.grimshot
        waybar
        wofi
      ];
    };
  };
  powerManagement.powertop.enable = true;
  fonts = {
    fonts = with pkgs; [
      nerdfonts
      inter
      fantasque-sans-mono
      xorg.fontbh100dpi
      mplus-outline-fonts
      symbola
      input-fonts
      output-fonts
      twemoji-color-font
      scientifica
    ];
    fontconfig = {
      enable = true;
      dpi = 96;
      defaultFonts = {
        serif = [
          "Inter"
          "Output Sans Semi-Condensed"
        ];
        sansSerif = [
          "Inter"
          "Output Sans Semi-Condensed"
        ];
        monospace = [
          "FantasqueSansMono Nerd Font"
          "Input Mono Condensed"
        ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
  system = {
    stateVersion = "21.03";
    autoUpgrade = {
      enable = true;
      flags = [ "--update-input" "nixpkgs" "--commit-lock-file" ];
    };
  };
}

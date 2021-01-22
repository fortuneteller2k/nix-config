{ config, lib, pkgs, ... }:

{
  programs = {
    home-manager.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacsGit;
      extraPackages = epkgs: with epkgs; [ vterm pdf-tools ];
    };
    urxvt = {
      enable = true;
      fonts = [ "xft:monospace:size=10:antialias=true" ];
      scroll.bar.enable = false;
      iso14755 = false;
      extraConfig = {
        letterSpace = 0;
        lineSpace = 0;
      };
    };
    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraConfig = (import ./config/neovim.nix);
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      userSettings = (import ./config/vscode.nix);
    };
    alacritty = {
      enable = true;
      settings = (import ./config/alacritty.nix);
    };
    starship = {
      enable = true;
      settings.format =
        "[fortuneteller2k](bold red) at [superfluous](bold blue) in $all ";
    };
    qutebrowser = {
      enable = true;
      extraConfig = (import ./config/qutebrowser.nix);
    };
    zathura = {
      enable = true;
      package = pkgs.zathura;
      extraConfig = "map <C-i> recolor";
      options = (import ./config/zathura.nix);
    };
    ncmpcpp = {
      enable = true;
      settings = (import ./config/ncmpcpp.nix);
    };
    mako = {
      enable = true;
      extraConfig = (import ./config/mako.nix);
    };
    waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        height = 18;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-right = [ "battery" "pulseaudio" "network" "clock" ];
        modules = (import ./config/waybar-modules.nix);
      }];
      style = (import ./config/waybar-style.nix);
    };
  };
  services = {
    dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus";
        size = "32x32";
        package = pkgs.papirus-icon-theme;
      };
      settings = (import ./config/dunst.nix);
    };
    polybar = {
      enable = true;
      script = "polybar main &";
      config = (import ./config/polybar.nix);
    };
    mpd = {
      enable = true;
      musicDirectory = "/home/fortuneteller2k/Music";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "mpd pulse-audio-output"
        }
        audio_output {
          type "fifo"
          name "mpd_visualizer_fifo"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = { 
      keybindings = { };
      bars = [ { command = "${pkgs.waybar}/bin/waybar"; } ];
    };
    extraConfig = (import ./config/sway.nix);
  };
  gtk = {
    enable = true;
    font.name = "Inter";
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.phocus;
      name = "fortuneteller2k_phocus";
    };
  };
  home = {
    packages = with pkgs; [
      betterdiscordctl
      bpytop
      brave
      cmus
      discocss
      discord
      emacs-all-the-icons-fonts
      exa
      fzf
      geogebra6
      gimp
      gitAndTools.gh
      gnvim
      graphviz
      hakuneko
      htop
      hyperfine
      inkscape
      krita
      mpc_cli
      mpv-with-scripts
      neofetch
      nix-top
      obs-studio
      peek
      pfetch
      qutebrowser
      ripcord
      scroll
      sonata
      speedtest-cli
      st
      sxiv
      texlive.combined.scheme-medium
      ytmdl
    ];
    sessionPath = [ "\${xdg.configHome}/emacs/bin" ];
    sessionVariables.EDITOR = "emacsclient -nc";
    username = "fortuneteller2k";
    homeDirectory = "/home/fortuneteller2k";
    stateVersion = "21.03";
  };
  fonts.fontconfig.enable = true;
  xresources.extraConfig = (import ./config/xresources.nix);
}

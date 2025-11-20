# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  pkgsUnstable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) {
    # Pass the nixpkgs config to the unstable alias to ensure `allowUnfree = true;` is propagated.
    config = config.nixpkgs.config;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  # networking.networkmanager.enable = true;
  networking = {
    networkmanager.enable = true;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    networkmanager.dns = "none";
  };

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable VMware tools.
  virtualisation.vmware.guest.enable = true;

  # Enable the Pantheon Desktop Environment.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "severchyk";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeter.enable = false;
  services.xserver.desktopManager.pantheon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.severchyk = {
    isNormalUser = true;
    description = "Severyn Matsiak";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable home-manager for user account.
  home-manager.useGlobalPkgs = true;
  home-manager.users.severchyk = { pkgs, ... }: {
    # home.packages = [ pkgs.atool pkgs.httpie ];

    # Configure ~/.bashrc
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        #if [ "$XDG_CURRENT_DESKTOP" = "Pantheon" ]; then
        #if neofetch | grep -q "io.elementary."; then
        if [[ "$GIO_LAUNCHED_DESKTOP_FILE" == *"io.elementary.terminal.desktop"* ]]; then
          neofetch
        fi
      '';
      initExtra = ''
        du() {
          command du -h --max-depth 1 "$@" | sort -hr
        }
        rssh() {
          ssh $(grep -E '^Host ' ~/.ssh/config | cut -d ' ' -f2 | sort | fzf)
        }
        rmc() {
          MC_PROFILE_ROOT=~/.mc-server-connect mc sftp://$(grep -E '^Host ' ~/.ssh/config | cut -d ' ' -f2 | sort | fzf)
        }
      '';
      shellAliases = {
        # Add colors for filetype and  human-readable sizes by default on 'ls':
        ls = "ls -h --color=auto";
        lx = "ls -lXB";  # Sort by extension.
        lk = "ls -lSr";  # Sort by size, biggest last.
        lt = "ls -ltr";  # Sort by date, most recent last.
        lc = "ls -ltcr"; # Sort by/show change time, most recent last.
        lu = "ls -ltur"; # Sort by/show access time, most recent last.

        # The ubiquitous 'll': directories first, with alphanumeric sorting:
        ll = "ls -alv --group-directories-first";
        lm = "ll | more";    #  Pipe through 'more'
        lr = "ll -R";        #  Recursive ls.
        la = "ll -A";        #  Show hidden files.
        tree = "tree -Csuh"; #  Nice alternative to 'recursive ls' ...

        df = "df -h";
        free = "free -h";

        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";

        ".." = "cd ..";
      };
      shellOptions = [
        "checkwinsize"
        "globstar"
        "histappend"
      ];
    };

    # Install VSCode.
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          # ms-vscode.remote-explorer
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          redhat.vscode-yaml
        ] ++ (with pkgs.unstable.vscode-extensions; [
          ms-vscode.remote-explorer
        ]);
        userSettings = {
          "explorer.confirmDelete" = false;
          "files.autoSave" = "onFocusChange";
          "files.trimFinalNewlines" = true;
          "files.trimTrailingWhitespace" = true;
          "redhat.telemetry.enabled" = false;
          "terminal.integrated.fontFamily" = "Roboto Mono";
        };
      };
    };

    # Install waveterm
    programs.waveterm = {
      enable = true;
      settings = {
        "autoupdate:channel" = "latest";
        "conn:askbeforewshinstall" = false;
        "conn:wshenabled" = false;
        "telemetry:enabled" = false;
        "term:fontsize" = 14;
        "term:transparency" = 0.5;
        "window:magnifiedblockblurprimarypx" = 10;
        "window:magnifiedblockblursecondarypx" = 10;
        "window:magnifiedblockopacity" = 0.3;
        "window:magnifiedblocksize" = 1;
        "window:nativetitlebar" = true;
        "window:opacity" = 0.7;
        "window:showmenubar" = false;
        "window:tilegapsize" = 10;
        "window:transparent" = true;
      };
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.
  };

  # Install firefox.
  # programs.firefox.enable = true;

  # Enable policies for chromium based browsers like Chromium, Google Chrome or Brave.
  programs.chromium = {
    enable = true;
    extensions = [
      "gighmmpiobklfepjocnamgkkbiglidom;https://clients2.google.com/service/update2/crx" # adblock
      "ghbmnnjooekpmoecnnnilnnbdlolhkhi;https://clients2.google.com/service/update2/crx" # google docs offline
      "aapbdbdomjkkjkaonfhkkikfgjllcleb;https://clients2.google.com/service/update2/crx" # google translate
      "ailcmbgekjpnablpdkmaaccecekgdhlh;https://clients2.google.com/service/update2/crx" # workona
    ];
    extraOpts = {
      "RestoreOnStartup" = 1;
      /* "WebAppInstallForceList" = [
        {
          "custom_name" = "Google Meet";
          "create_desktop_shortcut" = false;
          "default_launch_container" = "window";
          "url" = "https://meet.google.com";
        }
      ]; */
    };
  };

  # Allow unfree packages.
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = pkgsUnstable;
    };
  };

  # Install Docker.
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    atop
    awscli2
    bat
    chromium
    fzf
    ghostty
    git
    htop
    ipfetch
    jq
    jqp
    kubectl
    lazycli
    lazydocker
    lazygit
    lazyjournal
    lazysql
    # lazyssh
    mc
    neofetch
    # slacky
    terminator
    tree
    unzip
    vim
    # vscode
    warp-terminal
    # waveterm
    wezterm
    wget
  ] ++ (with pkgs.unstable; [
    lazyssh
    slacky
  ]);

  # Enable automatic upgrades.
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = "https://channels.nixos.org/nixos-25.05";
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}

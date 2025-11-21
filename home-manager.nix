{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # Enable home-manager for user account.
  home-manager.useGlobalPkgs = true;
  home-manager.users.severchyk = { pkgs, ... }: {

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
          "extensions.ignoreRecommendations" = true;
          "files.autoSave" = "onFocusChange";
          "files.trimFinalNewlines" = true;
          "files.trimTrailingWhitespace" = true;
          "redhat.telemetry.enabled" = false;
          "terminal.integrated.fontFamily" = "Roboto Mono";
        };
      };
    };

    # Install waveterm.
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
}

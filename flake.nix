{
description = "Johnseth97 Darwin system flake";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, config, ... }: {
      
      # Nix Packages
      environment.systemPackages = [
       
        # Terminal

          # Prompt
          pkgs.starship

          # Plugin manager
          pkgs.antidote
          
          # Terminal tools
          pkgs.git
          pkgs.fzf
          pkgs.wget
          pkgs.fd
          pkgs.ripgrep
          pkgs.stow
          
          # Terminal apps
          pkgs.btop
          pkgs.neovim
          pkgs.lazygit
          
          # Utilities
          pkgs.fontforge
          pkgs.neofetch
          pkgs.sl
          pkgs.lolcat
          pkgs.charasay

        # programming languages
          
          # Javascript
          pkgs.nodejs

          # Rust
          pkgs.cargo

          # Python
          pkgs.python3

          # Go
          pkgs.go

          # Lua
          pkgs.lua
          pkgs.luarocks
          
        
        # keyboards
        pkgs.qmk

        # cybersecurity
        pkgs.nmap

        # security
        pkgs.gnupg

        # terminal emulators        
        pkgs.iterm2
        pkgs.wezterm

        # dev apps
        pkgs.vscode

        # virtualization
        pkgs.utm

        # productivity
        pkgs.gimp
        
        # social
        pkgs.discord
        
      ];
      
      # fonts configuration
      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ "Lilex" ]; })
      ];
      
      # Enable Homebrew
      homebrew = {
        enable = true;
        taps = [
          # Mullvad VPN
          "jorgelbg/tap"

          # Wezterm
          "nikitabobko/tap"

          # Yabai
          "koekeishiya/formulae"

          # Sketchybar
          "FelixKratz/formulae"

          # skhd
          "koekeishiya/formulae"
        ];

        casks = [
          "mullvadvpn"
          "metasploit"
          # Window Management
          # "aerospace"
          # "wezterm"
          "zoom"
          
        ];

        brews = [
          "pinentry-mac"
          "pinentry-touchid"
          "mas"
          "sketchybar"
          "yabai"
          "skhd"
        ];

        masApps = {
          "AdGuard" = 1440147259;
          "Noir" = 1592917505;
          "Windows App" = 1295203466;
          };


      };
      
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Allow broken packages
      nixpkgs.config.allowBroken = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."MacbookPro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacbookPro".pkgs;
  };
}

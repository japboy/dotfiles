{
  description = "WSL environment packages";

  inputs = {
    common-nix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs-essentials.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-recent-version-packages.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, ... }:
    let
      commonNix = inputs."common-nix";
      nixpkgsEssentials = inputs."nixpkgs-essentials";
      nixpkgsRecentVersionPackages = inputs."nixpkgs-recent-version-packages";
      system = "x86_64-linux";
      essentialPkgs = import nixpkgsEssentials {
        inherit system;
        config.allowUnfree = true;
      };
      recentVersionPkgs = import nixpkgsRecentVersionPackages {
        inherit system;
        config.allowUnfree = true;
      };
      recentVersionPackages = import "${commonNix}/packages/recent-version-packages.nix" { pkgs = recentVersionPkgs; };
      mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { pkgs = recentVersionPkgs; };
      python = essentialPkgs.python3.withPackages (pythonPackages: with pythonPackages; [
        pip
        pynvim
        wheel
      ]);
      essentialPackages = with essentialPkgs; [
        # Fundamental tools
        blesh
        chromium
        cmake
        curl
        direnv
        fzf
        gcc
        gh
        git
        gnumake
        neovim
        nil
        nixd
        ripgrep
        unzip
        wget

        # Language runtimes
        bun
        deno
        go
        nodejs_22
        powershell
        python
        ruby
        rustup
        uv
      ];
    in
    {
      packages.${system}.default = essentialPkgs.buildEnv {
        name = "wsl-packages";
        paths = essentialPackages ++ recentVersionPackages ++ mcpPackages;
      };
    };
}

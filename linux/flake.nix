{
  description = "WSL environment packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "wsl-packages";
        paths = with pkgs; [
          # Fundamental tools
          blesh
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
          python3
          rustup
        ];
      };
    };
}

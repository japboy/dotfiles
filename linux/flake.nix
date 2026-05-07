{
  description = "WSL environment packages";

  inputs = {
    commonNix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, commonNix, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { inherit pkgs; };
      python = pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
        pip
        pynvim
        wheel
      ]);
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
          mise
          nodejs_22
          python
          ruby
          rustup
          uv

          # MCP servers
          mcpPackages.chromeDevtoolsMcp
          mcpPackages.mcpServerFetch
          mcpPackages.mcpServerFilesystem
          mcpPackages.playwrightMcp
          mcpPackages.serena
        ];
      };
    };
}

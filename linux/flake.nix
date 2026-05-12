{
  description = "WSL environment packages";

  inputs = {
    common-nix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs-essentials.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-ai-clis.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, ... }:
    let
      commonNix = inputs."common-nix";
      nixpkgsEssentials = inputs."nixpkgs-essentials";
      nixpkgsAiClis = inputs."nixpkgs-ai-clis";
      system = "x86_64-linux";
      essentialPkgs = import nixpkgsEssentials {
        inherit system;
        config.allowUnfree = true;
      };
      aiCliPkgs = import nixpkgsAiClis {
        inherit system;
        config.allowUnfree = true;
      };
      aiCliPackages = import "${commonNix}/packages/ai-clis.nix" { pkgs = aiCliPkgs; };
      mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { pkgs = aiCliPkgs; };
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
        mise
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
        paths = essentialPackages ++ aiCliPackages ++ mcpPackages;
      };
    };
}

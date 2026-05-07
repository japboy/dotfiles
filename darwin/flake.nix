{
  description = "macOS environment packages";

  inputs = {
    commonNix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, commonNix, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkPackages = pkgs:
        let
          mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { inherit pkgs; };

          highway = pkgs.stdenv.mkDerivation rec {
            pname = "highway";
            version = "1.1.0";

            src = pkgs.fetchFromGitHub {
              owner = "tkengo";
              repo = "highway";
              rev = "v${version}";
              hash = "sha256-Vd5ZcZx8z0HWAL5e0zXAM5j8lOwksV969A4YL0u+Yo4=";
            };

            nativeBuildInputs = with pkgs; [
              autoreconfHook
              pkg-config
            ];

            buildInputs = with pkgs; [
              gperftools
            ];

            meta = with pkgs.lib; {
              description = "High performance source code search tool";
              homepage = "https://github.com/tkengo/highway/";
              license = licenses.mit;
              mainProgram = "hw";
              platforms = platforms.darwin;
            };
          };

          glanceChamburr = pkgs.stdenvNoCC.mkDerivation rec {
            pname = "glance-chamburr";
            version = "1.5.4";

            src = pkgs.fetchurl {
              url = "https://github.com/chamburr/glance/releases/download/v${version}/Glance-${version}.dmg";
              hash = "sha256-8t8RToO4uDTC2p1M+9TTMHqPBWOp5hO/3Yi0s7/+Ya0=";
            };

            sourceRoot = ".";

            # Glance DMG uses APFS, which is not supported by undmg.
            nativeBuildInputs = with pkgs; [
              _7zz
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p "$out/Applications"
              cp -R "Glance.app" "$out/Applications/"
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Quick Look previews for files that are not natively supported";
              homepage = "https://github.com/chamburr/glance";
              license = licenses.mit;
              platforms = platforms.darwin;
            };
          };

          thePlatinumSearcher = pkgs.stdenvNoCC.mkDerivation rec {
            pname = "the_platinum_searcher";
            version = "2.2.0";

            # Upstream only publishes darwin_amd64 assets for v2.2.0.
            # Apple Silicon hosts use Rosetta, which bootstrap-darwin.sh installs.
            src = pkgs.fetchurl {
              url = "https://github.com/monochromegane/the_platinum_searcher/releases/download/v${version}/pt_darwin_amd64.zip";
              hash = "sha256-d/LBuIsTuemSRt9rEZ81tY1hfyg0SjQNaJfDbJ0jr3U=";
            };

            sourceRoot = "pt_darwin_amd64";

            nativeBuildInputs = with pkgs; [
              unzip
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p "$out/bin"
              install -m 0755 pt "$out/bin/pt"
              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Code search tool similar to ack and ag";
              homepage = "https://github.com/monochromegane/the_platinum_searcher";
              license = licenses.mit;
              mainProgram = "pt";
              platforms = platforms.darwin;
            };
          };

          python = pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
            pip
            pynvim
            wheel
          ]);
        in
        pkgs.buildEnv {
          name = "darwin-packages";
          paths = with pkgs; [
            # Fundamental tools
            autoconf
            automake
            cairo
            ccache
            cmake
            curl
            direnv
            gettext
            gh
            giflib
            git
            git-extras
            grc
            highway
            jdk
            libjpeg
            libmcrypt
            libpng
            librsvg
            libtiff
            libwebp
            lua
            mcrypt
            neovim
            ngrok
            openssl
            pango
            pcre
            pkg-config
            re2c
            readline
            ripgrep
            scons
            selenium-server-standalone
            silver-searcher
            thePlatinumSearcher
            universal-ctags
            unzip
            uv
            wget
            xz

            # Zsh integrations
            zsh-autosuggestions
            zsh-completions
            zsh-syntax-highlighting

            # Language runtimes and package managers
            bun
            deno
            go
            nodejs_22
            mise
            pnpm
            python
            ruby
            rustup
            yarn

            # MCP servers
            mcpPackages.chromeDevtoolsMcp
            mcpPackages.mcpServerFetch
            mcpPackages.mcpServerFilesystem
            mcpPackages.playwrightMcp
            mcpPackages.serena

            # macOS applications
            glanceChamburr
          ];
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkPackages (mkPkgs system);
      });
    };
}

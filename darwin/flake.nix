{
  description = "macOS environment packages";

  inputs = {
    common-nix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs-essentials.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-ai-clis.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, ... }:
    let
      commonNix = inputs."common-nix";
      nixpkgsEssentials = inputs."nixpkgs-essentials";
      nixpkgsAiClis = inputs."nixpkgs-ai-clis";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgsEssentials.lib.genAttrs systems;

      mkEssentialPkgs = system: import nixpkgsEssentials {
        inherit system;
        config.allowUnfree = true;
      };

      mkAiCliPkgs = system: import nixpkgsAiClis {
        inherit system;
        config.allowUnfree = true;
      };

      mkPackages = essentialPkgs: aiCliPkgs:
        let
          aiCliPackages = import "${commonNix}/packages/ai-clis.nix" { pkgs = aiCliPkgs; };
          mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { pkgs = essentialPkgs; };

          highway = essentialPkgs.stdenv.mkDerivation rec {
            pname = "highway";
            version = "1.1.0";

            src = essentialPkgs.fetchFromGitHub {
              owner = "tkengo";
              repo = "highway";
              rev = "v${version}";
              hash = "sha256-Vd5ZcZx8z0HWAL5e0zXAM5j8lOwksV969A4YL0u+Yo4=";
            };

            nativeBuildInputs = with essentialPkgs; [
              autoreconfHook
              pkg-config
            ];

            buildInputs = with essentialPkgs; [
              gperftools
            ];

            meta = with essentialPkgs.lib; {
              description = "High performance source code search tool";
              homepage = "https://github.com/tkengo/highway/";
              license = licenses.mit;
              mainProgram = "hw";
              platforms = platforms.darwin;
            };
          };

          glanceChamburr = essentialPkgs.stdenvNoCC.mkDerivation rec {
            pname = "glance-chamburr";
            version = "1.5.4";

            src = essentialPkgs.fetchurl {
              url = "https://github.com/chamburr/glance/releases/download/v${version}/Glance-${version}.dmg";
              hash = "sha256-8t8RToO4uDTC2p1M+9TTMHqPBWOp5hO/3Yi0s7/+Ya0=";
            };

            sourceRoot = ".";

            # Glance DMG uses APFS, which is not supported by undmg.
            nativeBuildInputs = with essentialPkgs; [
              _7zz
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p "$out/Applications"
              cp -R "Glance.app" "$out/Applications/"
              runHook postInstall
            '';

            meta = with essentialPkgs.lib; {
              description = "Quick Look previews for files that are not natively supported";
              homepage = "https://github.com/chamburr/glance";
              license = licenses.mit;
              platforms = platforms.darwin;
            };
          };

          thePlatinumSearcher = essentialPkgs.stdenvNoCC.mkDerivation rec {
            pname = "the_platinum_searcher";
            version = "2.2.0";

            # Upstream only publishes darwin_amd64 assets for v2.2.0.
            # Apple Silicon hosts use Rosetta, which bootstrap-darwin.sh installs.
            src = essentialPkgs.fetchurl {
              url = "https://github.com/monochromegane/the_platinum_searcher/releases/download/v${version}/pt_darwin_amd64.zip";
              hash = "sha256-d/LBuIsTuemSRt9rEZ81tY1hfyg0SjQNaJfDbJ0jr3U=";
            };

            sourceRoot = "pt_darwin_amd64";

            nativeBuildInputs = with essentialPkgs; [
              unzip
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p "$out/bin"
              install -m 0755 pt "$out/bin/pt"
              runHook postInstall
            '';

            meta = with essentialPkgs.lib; {
              description = "Code search tool similar to ack and ag";
              homepage = "https://github.com/monochromegane/the_platinum_searcher";
              license = licenses.mit;
              mainProgram = "pt";
              platforms = platforms.darwin;
            };
          };

          python = essentialPkgs.python3.withPackages (pythonPackages: with pythonPackages; [
            pip
            pynvim
            wheel
          ]);

          essentialPackages = with essentialPkgs; [
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
            nil
            nixd
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
            powershell
            python
            ruby
            rustup
            yarn
          ];

          appPackages = [
            glanceChamburr
          ];
        in
        essentialPkgs.buildEnv {
          name = "darwin-packages";
          paths =
            essentialPackages
            ++ aiCliPackages
            ++ mcpPackages
            ++ appPackages;
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkPackages (mkEssentialPkgs system) (mkAiCliPkgs system);
      });
    };
}

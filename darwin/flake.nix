{
  description = "macOS environment packages";

  inputs = {
    common-nix = {
      url = "path:../common/nix";
      flake = false;
    };

    nixpkgs-essentials.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-recent-version-packages.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs@{ self, ... }:
    let
      commonNix = inputs."common-nix";
      nixpkgsEssentials = inputs."nixpkgs-essentials";
      nixpkgsRecentVersionPackages = inputs."nixpkgs-recent-version-packages";
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgsEssentials.lib.genAttrs systems;

      mkEssentialPkgs =
        system:
        import nixpkgsEssentials {
          inherit system;
          config.allowUnfree = true;
        };

      mkRecentVersionPkgs =
        system:
        import nixpkgsRecentVersionPackages {
          inherit system;
          config.allowUnfree = true;
        };

      mkPackages =
        essentialPkgs: recentVersionPkgs:
        let
          recentVersionPackages = import "${commonNix}/packages/recent-version-packages.nix" {
            pkgs = recentVersionPkgs;
          };
          mcpPackages = import "${commonNix}/packages/mcp-servers.nix" { pkgs = recentVersionPkgs; };

          glanceChamburr = essentialPkgs.stdenvNoCC.mkDerivation rec {
            pname = "glance-chamburr";
            version = "1.6.0";

            src = essentialPkgs.fetchurl {
              url = "https://github.com/chamburr/glance/releases/download/v${version}/Glance-${version}.dmg";
              hash = "sha256-wYY5qO6q0V1SB/t3rllXSDn+y9bX9+IEpTpEUVAKIM8=";
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

          python = essentialPkgs.python3.withPackages (
            pythonPackages: with pythonPackages; [
              pip
              pynvim
              wheel
            ]
          );

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
            giflib
            git
            git-extras
            grc
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
            universal-ctags
            unzip
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
            nodejs_24
            pnpm
            powershell
            python
            ruby
            rustup
            uv
          ];

          appPackages = [
            glanceChamburr
          ];
        in
        essentialPkgs.buildEnv {
          name = "darwin-packages";
          paths = essentialPackages ++ recentVersionPackages ++ mcpPackages ++ appPackages;
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkPackages (mkEssentialPkgs system) (mkRecentVersionPkgs system);
      });
    };
}

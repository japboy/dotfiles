{ pkgs }:

let
  inherit (pkgs) lib;

  pythonPackages = pkgs.python3Packages;

  mcp_1_27 = pythonPackages.mcp.overridePythonAttrs (oldAttrs: rec {
    version = "1.27.0";

    src = pkgs.fetchFromGitHub {
      owner = "modelcontextprotocol";
      repo = "python-sdk";
      tag = "v${version}";
      hash = "sha256-qvbGyF0PVC626yCgUqOYmA1zOmvI3/bC7l7HhfOtKH8=";
    };
  });

  chromeDevtoolsMcp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "chrome-devtools-mcp";
    version = "0.25.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${version}.tgz";
      hash = "sha512-A6Zh3iH+O7lvjhUOQNxbxMy6KJhKnMtVKb+37oy4QcnDp7JEJYKkeqtsw4hFXJG5ISfNTVlaWxKsKLxRdJAAUA==";
    };

    sourceRoot = "package";

    nativeBuildInputs = [
      pkgs.makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      package_dir="$out/lib/node_modules/chrome-devtools-mcp"
      mkdir -p "$package_dir" "$out/bin"
      cp -R . "$package_dir"

      makeWrapper ${lib.getExe pkgs.nodejs_22} "$out/bin/chrome-devtools-mcp" \
        --add-flags "$package_dir/build/src/bin/chrome-devtools-mcp.js"
      makeWrapper ${lib.getExe pkgs.nodejs_22} "$out/bin/chrome-devtools" \
        --add-flags "$package_dir/build/src/bin/chrome-devtools.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "MCP server for Chrome DevTools";
      homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
      license = licenses.asl20;
      mainProgram = "chrome-devtools-mcp";
      platforms = platforms.all;
    };
  };

  serena = pythonPackages.buildPythonApplication rec {
    pname = "serena-agent";
    version = "1.2.0";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "serena_agent";
      inherit version;
      hash = "sha256-sisC9Ey8I+AvVV4W7NZUwWQ4uymO47xIWglBZCo7m3c=";
    };

    build-system = [
      pythonPackages.hatchling
    ];

    dependencies = with pythonPackages; [
      anthropic
      beautifulsoup4
      cryptography
      docstring-parser
      filelock
      flask
      jinja2
      joblib
      lsprotocol
      mcp_1_27
      overrides
      pathspec
      psutil
      pydantic
      pygls
      pystray
      python-dotenv
      python-multipart
      pywebview
      pyyaml
      regex
      requests
      ruamel-yaml
      sensai-utils
      starlette
      tiktoken
      tqdm
      types-pyyaml
      urllib3
      werkzeug
    ];

    pythonRelaxDeps = true;
    pythonRemoveDeps = [
      "dotenv"
      "fortls"
      "pyright"
      "pythonnet"
    ];

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        pkgs.fortls
        pkgs.pyright
      ])
    ];

    doCheck = false;

    meta = with lib; {
      description = "MCP toolkit for semantic code retrieval and editing";
      homepage = "https://github.com/oraios/serena";
      license = licenses.mit;
      mainProgram = "serena";
      platforms = platforms.unix;
    };
  };
in
{
  inherit
    chromeDevtoolsMcp
    serena;

  mcpServerFetch = pkgs.mcp-server-fetch;
  mcpServerFilesystem = pkgs.mcp-server-filesystem;
  playwrightMcp = pkgs.playwright-mcp;
}

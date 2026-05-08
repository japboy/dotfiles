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

  pyobjc-framework-UniformTypeIdentifiers = pythonPackages.buildPythonPackage rec {
    pname = "pyobjc-framework-UniformTypeIdentifiers";
    version = "11.1";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "ronaldoussoren";
      repo = "pyobjc";
      tag = "v${version}";
      hash = "sha256-2qPGJ/1hXf3k8AqVLr02fVIM9ziVG9NMrm3hN1de1Us=";
    };

    sourceRoot = "${src.name}/pyobjc-framework-UniformTypeIdentifiers";

    build-system = [
      pythonPackages.setuptools
    ];

    buildInputs = [
      pkgs.darwin.libffi
    ];

    nativeBuildInputs = [
      pkgs.darwin.DarwinTools
    ];

    postPatch = ''
      substituteInPlace pyobjc_setup.py \
        --replace-fail "-buildversion" "-buildVersion" \
        --replace-fail "-productversion" "-productVersion" \
        --replace-fail "/usr/bin/sw_vers" "sw_vers" \
        --replace-fail "/usr/bin/xcrun" "xcrun"
    '';

    dependencies = with pythonPackages; [
      pyobjc-core
      pyobjc-framework-Cocoa
    ];

    env.NIX_CFLAGS_COMPILE = toString [
      "-I${pkgs.darwin.libffi.dev}/include"
      "-Wno-error=unused-command-line-argument"
    ];

    pythonImportsCheck = [
      "UniformTypeIdentifiers"
      "PyObjCTools"
    ];

    meta = with lib; {
      description = "PyObjC wrappers for the UniformTypeIdentifiers framework on macOS";
      homepage = "https://github.com/ronaldoussoren/pyobjc";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
  };

  pywebview = pythonPackages.pywebview.overridePythonAttrs (oldAttrs: {
    dependencies = oldAttrs.dependencies ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      pyobjc-framework-UniformTypeIdentifiers
    ];
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
[
  chromeDevtoolsMcp
  pkgs.mcp-server-fetch
  pkgs.mcp-server-filesystem
  pkgs.playwright-mcp
  serena
]

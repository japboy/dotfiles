{ pkgs }:

let
  inherit (pkgs) lib;

  # Serena's security floor requires urllib3 newer than Nixpkgs provides.
  # Scope the override so transitive consumers use the same distribution.
  pythonPackages = pkgs.python3Packages.overrideScope (_final: previous: {
    anyio = previous.anyio.overridePythonAttrs (oldAttrs: {
      # The test tracks its own portal threads. Check their shutdown directly;
      # unrelated background threads can terminate during a global count check.
      # https://github.com/agronholm/anyio/issues/823
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace tests/test_to_thread.py \
          --replace-fail '        active_threads_before = threading.active_count()' "" \
          --replace-fail 'assert threading.active_count() == active_threads_before' \
            'assert all(not thread.is_alive() for thread in threads)'
      '';
    });

    urllib3 = previous.urllib3.overridePythonAttrs (_oldAttrs: rec {
      version = "2.8.0";
      src = pkgs.fetchPypi {
        pname = "urllib3";
        inherit version;
        hash = "sha256-Y78urUyHlCbr8i7yp4HutKo7SueYoENVBvhof9W7m2M=";
      };
    });
  });

  # MCP 2 split its wire types into a separate distribution.
  mcp-types = pythonPackages.buildPythonPackage rec {
    pname = "mcp-types";
    version = "2.2.0";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "mcp_types";
      inherit version;
      hash = "sha256-0+1TcD3dENnGOZ8p0yK7ZvP2erQTSKyFVroj4H/t760=";
    };

    build-system = with pythonPackages; [
      hatchling
      uv-dynamic-versioning
    ];
    dependencies = with pythonPackages; [
      pydantic
      typing-extensions
    ];
    pythonImportsCheck = [ "mcp_types" ];

    meta = {
      description = "Model Context Protocol wire types";
      homepage = "https://github.com/modelcontextprotocol/python-sdk";
      license = lib.licenses.mit;
    };
  };

  mcp = pythonPackages.buildPythonPackage rec {
    pname = "mcp";
    version = "2.2.0";
    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-LcN+yxl0vs3Ovb91YefBWgfbvyC6IboWw1k7MDizr70=";
    };

    build-system = with pythonPackages; [
      hatchling
      uv-dynamic-versioning
    ];
    dependencies = with pythonPackages; [
      anyio
      httpx2
      jsonschema
      mcp-types
      opentelemetry-api
      pydantic
      pyjwt
      python-multipart
      sse-starlette
      starlette
      typing-extensions
      typing-inspection
      uvicorn
    ] ++ pyjwt.optional-dependencies.crypto;
    pythonImportsCheck = [
      "mcp"
      "mcp.server"
      "mcp.client"
    ];

    meta = {
      description = "Official Python SDK for Model Context Protocol servers and clients";
      homepage = "https://github.com/modelcontextprotocol/python-sdk";
      license = lib.licenses.mit;
    };
  };

  # Serena 2.1 uses the Anthropic 0.x API, rather than the Nixpkgs 1.x API.
  anthropic = pythonPackages.buildPythonPackage rec {
    pname = "anthropic";
    version = "0.117.0";
    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-mBB/K3ZDlkHgrioXVAh1NLjxeNurmdbrG8S3vIx0RJY=";
    };

    build-system = with pythonPackages; [
      hatchling
      hatch-fancy-pypi-readme
    ];
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail '"hatchling==1.26.3"' '"hatchling>=1.26.3"'
    '';
    dependencies = with pythonPackages; [
      anyio
      distro
      docstring-parser
      httpx
      jiter
      pydantic
      sniffio
      typing-extensions
    ];
    pythonImportsCheck = [ "anthropic" ];

    meta = {
      description = "Anthropic Python SDK used by Serena";
      homepage = "https://github.com/anthropics/anthropic-sdk-python";
      license = lib.licenses.mit;
    };
  };

  pyobjc = rec {
    version = "12.2.2";

    src = pkgs.fetchFromGitHub {
      owner = "ronaldoussoren";
      repo = "pyobjc";
      tag = "v${version}";
      hash = "sha256-jtThPYaKWtIUzcaWxg34QxZc2ejCnSulwsjEUiTfb2Y=";
    };
  };

  pyobjcFrameworkPostPatch = ''
    substituteInPlace pyobjc_setup.py \
      --replace-warn "-buildversion" "-buildVersion" \
      --replace-warn "-productversion" "-productVersion" \
      --replace-fail "/usr/bin/sw_vers" "sw_vers" \
      --replace-fail "/usr/bin/xcrun" "xcrun"
  '';

  pyobjc-core = pythonPackages.pyobjc-core.overridePythonAttrs (_oldAttrs: {
    inherit (pyobjc) version src;

    sourceRoot = "${pyobjc.src.name}/pyobjc-core";
  });

  overridePyobjcFramework =
    frameworkName: package: dependencies:
    package.overridePythonAttrs (_oldAttrs: {
      inherit (pyobjc) version src;

      sourceRoot = "${pyobjc.src.name}/pyobjc-framework-${frameworkName}";

      postPatch = pyobjcFrameworkPostPatch;

      inherit dependencies;
    });

  pyobjc-framework-Cocoa = overridePyobjcFramework "Cocoa" pythonPackages.pyobjc-framework-Cocoa [
    pyobjc-core
  ];

  pyobjc-framework-Quartz = overridePyobjcFramework "Quartz" pythonPackages.pyobjc-framework-Quartz [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyobjc-framework-Security = overridePyobjcFramework "Security" pythonPackages.pyobjc-framework-Security [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyobjc-framework-WebKit = overridePyobjcFramework "WebKit" pythonPackages.pyobjc-framework-WebKit [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyobjc-framework-UniformTypeIdentifiers = pythonPackages.buildPythonPackage rec {
    pname = "pyobjc-framework-UniformTypeIdentifiers";
    pyproject = true;

    inherit (pyobjc) version src;

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

    postPatch = pyobjcFrameworkPostPatch;

    dependencies = [
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

  pyobjcPackageNames = [
    "pyobjc-core"
    "pyobjc-framework-Cocoa"
    "pyobjc-framework-Quartz"
    "pyobjc-framework-Security"
    "pyobjc-framework-UniformTypeIdentifiers"
    "pyobjc-framework-WebKit"
  ];

  isPyobjcPackage = dependency:
    lib.elem (dependency.pname or null) pyobjcPackageNames;

  pywebviewDarwinPyobjcDependencies = [
    pyobjc-core
    pyobjc-framework-Cocoa
    pyobjc-framework-Quartz
    pyobjc-framework-Security
    pyobjc-framework-UniformTypeIdentifiers
    pyobjc-framework-WebKit
  ];

  # Nixpkgs marks its Darwin package broken. Define the upstream release and
  # its Darwin PyObjC 12.2.2 dependencies explicitly; use Qt only on Linux.
  pywebview = pythonPackages.buildPythonPackage rec {
    pname = "pywebview";
    version = "6.2";
    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-9Rv9CVdi/uPreCHGL+LA3dOcn+zY8z1RqHERPxLzZOE=";
    };
    build-system = [ pythonPackages.setuptools-scm ];
    dependencies = with pythonPackages; [
      bottle
      proxy-tools
      typing-extensions
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin pywebviewDarwinPyobjcDependencies
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pyside6
      qtpy
    ];
    pythonImportsCheck = [ "webview" ];

    meta = {
      description = "Lightweight cross-platform wrapper around a webview";
      homepage = "https://github.com/r0x0r/pywebview";
      license = lib.licenses.bsd3;
    };
  };

  pystray = pythonPackages.pystray.overridePythonAttrs (oldAttrs: {
    propagatedBuildInputs =
      lib.filter (dependency: !isPyobjcPackage dependency) oldAttrs.propagatedBuildInputs
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pyobjc-framework-Quartz
      ];
  });

  chromeDevtoolsMcp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "chrome-devtools-mcp";
    version = "1.11.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${version}.tgz";
      hash = "sha512-CytJ/5tnzrS+J/74be2P5aCOsS/mmGRHys/Si+IYC4ucrbnWAmES/dYdxGJjeUCECRcoFUilZAysdjlwqUjXIA==";
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
    version = "2.1.0";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "serena_agent";
      inherit version;
      hash = "sha256-MSyMfLP6cOP6f+RoXglZTjHpqdfQkNWRNqD68vqTmpE=";
    };

    # Upstream 2.x defaults to uvx for these servers. Use the Nix dependencies
    # already provided by this package, while preserving explicit user settings.
    postPatch = ''
      substituteInPlace src/solidlsp/language_servers/pyright_server.py \
        --replace-fail '            self._custom_settings,' \
          '            SolidLSPSettings.CustomLSSettings({
                      "ls_path": "${lib.getExe' pkgs.pyright "pyright-langserver"}",
                      **self._custom_settings.settings,
                  }),'
      substituteInPlace src/solidlsp/language_servers/fortran_language_server.py \
        --replace-fail '            self._custom_settings,' \
          '            SolidLSPSettings.CustomLSSettings({
                      "ls_path": "${lib.getExe pkgs.fortls}",
                      **self._custom_settings.settings,
                  }),'
      substituteInPlace src/solidlsp/language_servers/fortran_language_server.py \
        --replace-fail '            version_setting_key="fortls_version",' \
          '            version_setting_key="fortls_version",
                  extra_args=("--disable_autoupdate",),'
    '';

    build-system = [
      pythonPackages.hatchling
    ];

    dependencies = with pythonPackages; [
      anthropic
      beautifulsoup4
      click
      cryptography
      docstring-parser
      filelock
      flask
      jinja2
      joblib
      lsprotocol
      mcp
      oslex
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

    # Upstream exact-pins its uv environment. Keep major/API migrations and
    # missing minimum versions explicit above; relax only these Nixpkgs versions.
    pythonRelaxDeps = [
      "beautifulsoup4"
      "click"
      "cryptography"
      "docstring-parser"
      "filelock"
      "joblib"
      "pathspec"
      "psutil"
      "pydantic"
      "python-dotenv"
      "python-multipart"
      "pyyaml"
      "regex"
      "requests"
      "ruamel.yaml"
      "sensai-utils"
      "starlette"
      "tqdm"
      "types-pyyaml"
      "werkzeug"
    ];

    # Importing MemoryManager creates Serena's global-memory directory.
    # Keep that state inside the build sandbox, without changing user defaults.
    preDistPhases = [ "prepareSerenaImportState" ];
    prepareSerenaImportState = ''
      export SERENA_HOME="$TMPDIR/serena-import-check"
      mkdir -p "$SERENA_HOME"
    '';
    pythonImportsCheck = [
      "serena.cli"
      "serena.mcp"
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
      license = licenses.gpl3Plus;
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

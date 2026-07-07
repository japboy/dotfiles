{ pkgs }:

let
  inherit (pkgs) lib;

  pythonPackages = pkgs.python3Packages;

  mcp_1_27_1 = pythonPackages.mcp.overridePythonAttrs (_oldAttrs: rec {
    version = "1.27.1";

    src = pkgs.fetchFromGitHub {
      owner = "modelcontextprotocol";
      repo = "python-sdk";
      tag = "v${version}";
      hash = "sha256-LhoLcFC5+7xOCfud23sbHyTMxKYmdeZh0c+UtGdvzCs=";
    };
  });

  pyobjc = rec {
    version = "12.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "ronaldoussoren";
      repo = "pyobjc";
      tag = "v${version}";
      hash = "sha256-8Yv0HtE2ToiuIK/SJbvPCkfJ8ITHBfkZ+4Tb7wLJVTM=";
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

  pywebview = pythonPackages.pywebview.overridePythonAttrs (oldAttrs: {
    dependencies =
      lib.filter (dependency: !isPyobjcPackage dependency) oldAttrs.dependencies
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin pywebviewDarwinPyobjcDependencies;
  });

  pystray = pythonPackages.pystray.overridePythonAttrs (oldAttrs: {
    propagatedBuildInputs =
      lib.filter (dependency: !isPyobjcPackage dependency) oldAttrs.propagatedBuildInputs
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pyobjc-framework-Quartz
      ];
  });

  chromeDevtoolsMcp = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "chrome-devtools-mcp";
    version = "1.2.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/chrome-devtools-mcp/-/chrome-devtools-mcp-${version}.tgz";
      hash = "sha512-xHd8hoLZQArDsYhu8OUHvKBIiihx1Co9DgAPHWaM4kzRf41TpZ0IuxKioIWTEGzFKpRqQzIxpFqydY4AKqP5sQ==";
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
    version = "1.5.3";
    pyproject = true;

    src = pkgs.fetchPypi {
      pname = "serena_agent";
      inherit version;
      hash = "sha256-6zhGCOEbdfvCkZbdlC9toolGBgiI7lsi52ryFoJfZ44=";
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
      mcp_1_27_1
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

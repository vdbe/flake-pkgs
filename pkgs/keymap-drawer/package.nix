{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:
let
  pname = "keymap-drawer";
  version = "0.22.1";
in
python3Packages.buildPythonApplication {
  inherit pname version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "caksoylar";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-X3O5yspEdey03YQ6JsYN/DE9NUiq148u1W6LQpUQ3ns=";
  };

  nativeBuildInputs = [ python3Packages.poetry-core ];

  build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = [
    python3Packages.pcpp
    python3Packages.platformdirs
    python3Packages.pydantic
    python3Packages.pydantic-settings
    python3Packages.pyparsing
    python3Packages.pyparsing
    python3Packages.pyyaml
    python3Packages.tree-sitter
    python3Packages.tree-sitter-grammars.tree-sitter-devicetree

  ];

  pythonRelaxDeps = [
    "tree-sitter"
    "tree-sitter-devicetree"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = [ "--version" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    mainProgram = "keymap";
    description = "Visualize keymaps that use advanced features like hold-taps and combos, with automatic parsing.";
    homepage = "https://github.com/caksoylar/keymap-drawer";
    license = lib.licenses.mit;
  };
}

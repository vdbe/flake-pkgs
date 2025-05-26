{
  lib,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,

  rustPlatform,
}:
rustPlatform.buildRustPackage (
  final:
  let
    cargoTOML = lib.importTOML "${final.src}/Cargo.toml";
  in
  {
    pname = cargoTOML.package.name;
    version = "0.2.0";
    # inherit (cargoTOML.package) version;

    src = fetchFromGitHub {
      owner = "vdbe";
      repo = "wait-online";
      rev = "v${final.version}";
      hash = "sha256-56Al1ibIHXv4aiRMbORbnoKvdQ++OZiu3GHAf+hH9oU=";
    };

    # useFetchCargoVendor = true;
    cargoHash = "sha256-8U7JlXghDBzp5OFr5QdOrHvkgk1LGnrrs8N2EG4cG30=";

    doCheck = true;

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgramArg = [ "--version" ];

    passthru = {
      updateScript = nix-update-script { };
    };

    meta = {
      license = lib.licenses.mit;
      mainProgram = "wait-online";
    };
  }
)

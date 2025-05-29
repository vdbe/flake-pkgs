{
  lib,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,

  stdenv,
  removeReferencesTo,
  rustPlatform,
  upx,

  lto ? true,
  optimizeSize ? stdenv.hostPlatform.isStatic,
  optimizeWithUpx ? false,
}:
rustPlatform.buildRustPackage (
  final:
  let
    cargoTOML = lib.importTOML "${final.src}/Cargo.toml";
  in
  {
    pname = cargoTOML.package.name;
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "vdbe";
      repo = "sshd-command";
      rev = "v${final.version}";
      hash = "sha256-HYtTTfeZUfx/e/q4AsAFWLBTwLEBY/qmNF8wbVu+/HQ=";
    };

    # useFetchCargoVendor = true;
    cargoHash = "sha256-Ky+Qc5GFXgJEtBnl4/qxSi2HJEpPP4wVMlaBGOJcE4o=";

    nativeBuildInputs =
      (lib.optional stdenv.hostPlatform.isStatic removeReferencesTo)
      ++ (lib.optional optimizeWithUpx upx);

    # `-C panic="abort"` breaks checks
    doCheck = !optimizeSize;

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];
    versionCheckProgramArg = [ "--version" ];

    postFixup = toString [
      (lib.optionalString stdenv.hostPlatform.isStatic ''
        find "$out" \
          -type f \
          -exec remove-references-to -t ${stdenv.cc.libc} '{}' +
      '')
      (lib.optionalString optimizeWithUpx ''
        upx --best --lzma "$out/bin/sshd-command"
      '')
    ];

    env =
      let
        rustFlags =
          lib.optionalAttrs lto {
            lto = "fat";
            embed-bitcode = "yes";
          }
          // lib.optionalAttrs optimizeSize {
            codegen-units = 1;
            opt-level = "s";
            panic = "abort";
            strip = "symbols";
          };
      in
      {
        RUSTFLAGS = toString (lib.mapAttrsToList (name: value: "-C ${name}=${toString value}") rustFlags);
      };

    passthru = {
      updateScript = nix-update-script { };
    };

    meta = {
      license = lib.licenses.mit;
      mainProgram = "sshd-command";
    };
  }
)

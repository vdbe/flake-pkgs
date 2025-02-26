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
rustPlatform.buildRustPackage rec {
  pname = "sshd-command";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "vdbe";
    repo = "sshd-command";
    rev = "v${version}";
    hash = "sha256-XFLth0mBX2Lcmqe9PHo16Le+N4wqN8KiqO3i3B4b0f4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-W5VVH/krOY+YdSecoK+IyylqoPCUBuHa7cqFZ7j3eKs=";

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

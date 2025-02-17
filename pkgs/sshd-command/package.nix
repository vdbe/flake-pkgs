{
  lib,
  fetchFromGitHub,
  nix-update-script,

  stdenv,
  removeReferencesTo,
  rustPlatform,
  upx,

  lto ? true,
  optimizeSize ? stdenv.hostPlatform.isStatic,
  optimizeWithUpx ? false,
}:
let
  fs = lib.fileset;
in
rustPlatform.buildRustPackage rec {
  pname = "sshd-command";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "vdbe";
    repo = "sshd-command";
    rev = "v${version}";
    hash = "sha256-+4zmdRp+4ratsb/Iql4kCXUrbXpkm/Pu2QbOqWmrY6w=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-G+edPAeUEPnsnzjRFLhhXKwhHA4Ly1IxfKD/orz9pyI=";

  nativeBuildInputs =
    (lib.optional stdenv.hostPlatform.isStatic removeReferencesTo)
    ++ (lib.optional optimizeWithUpx upx);

  # `-C panic="abort"` breaks checks
  doCheck = !optimizeSize;

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

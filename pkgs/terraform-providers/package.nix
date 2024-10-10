{
  lib,
  terraform-providers,
  writeShellApplication,
  nix-update,
  curlMinimal,
  jq,
}:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.trivial) importJSON;

  inherit (terraform-providers) mkProvider;

  list = importJSON ./providers.json;

  providerFile = "./pkgs/terraform-providers/providers.json";
  updateProvider = writeShellApplication {
    name = "terraform-provider-update";
    runtimeInputs = [
      curlMinimal
      jq
      nix-update
    ];
    text = ''
      provider="$1"
      homepage="$(jq -r ".''${provider}.homepage" ${providerFile})"
      current="$(jq -r ".''${provider}.rev" ${providerFile})"

      latest="$(curl -s "''${homepage//providers/v1/providers}" | jq -r '.tag')"
      if [[ "$current" == "$latest" ]]; then
        # Same version nothing todo
        exit
      fi

      # Update version
      tempfile="$(mktemp)"
      jq ".''${provider}.rev = \"''${latest}\"" ${providerFile} > "''${tempfile}"
      cp "''${tempfile}" ${providerFile}
      rm "''${tempfile}"

      # Update hashes
      nix-update --override-filename=${providerFile} --version=skip "terraform-providers.''${provider}"
    '';
  };

  automated-providers = mapAttrs (
    providerName: providerAttrs:
    (mkProvider providerAttrs).overrideAttrs {
      passthru.updateScript = [
        (lib.getExe updateProvider)
        providerName
      ];

    }
  ) list;

  # These are the providers that don't fall in line with the default model
  special-providers = { };

  actualProviders = automated-providers // special-providers;
in
actualProviders

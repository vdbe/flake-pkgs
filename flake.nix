{
  description = "My custom nix packages";

  nixConfig = {
    extra-substituters = [ "https://vdbe.cachix.org" ];
    extra-trusted-public-keys = [ "vdbe.cachix.org-1:ID9DIbnE6jHyJlQiwS7L7tFULJd1dsxt2ODAWE94nts=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs lib.systems.flakeExposed (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          function pkgs
        );

      derivations = forAllSystems (
        pkgs:
        let
          legacyPackages = self.legacyPackages.${pkgs.stdenv.hostPlatform.system};

          getPathFromLegacyPackage = path: lib.attrsets.getAttrFromPath path legacyPackages;
          filterAttrSet =
            value:
            builtins.removeAttrs value [
              "override"
              "overrideDerivation"
            ];

          derivationsToNestedListOfStringPaths =
            path:
            lib.attrsets.mapAttrsToList (
              n: v:
              let
                valuePath = path ++ [ n ];
              in
              if lib.isDerivation v then
                {
                  path = builtins.concatStringsSep "." valuePath;
                  package = v;
                }
              else
                derivationPathsFromPath valuePath
            );

          derivationPathsFromPath =
            path:
            lib.trivial.pipe path [
              getPathFromLegacyPackage
              filterAttrSet
              (derivationsToNestedListOfStringPaths path)
              lib.lists.flatten
            ];
        in
        derivationPathsFromPath [ ]
      );
    in
    {
      apps = forAllSystems (
        pkgs:
        let
          derivations' = derivations.${pkgs.stdenv.hostPlatform.system};

          derivationToUpdateEntry =
            {
              path,
              package,
            }:
            let
              inherit (package) name pname;
              attrPath = path;
              oldVersion = package.version;
              supportedFeatures = package.supportedFeatures or [ ];
              updateScript =
                package.updateScript or (throw "${attrPath} does not
              have an update script");
            in
            {
              inherit
                attrPath
                name
                oldVersion
                pname
                supportedFeatures
                updateScript
                ;
            };

          packagesJson = lib.trivial.pipe derivations' [
            (builtins.filter ({ package, ... }: builtins.hasAttr "updateScript" package))
            (builtins.map derivationToUpdateEntry)
            builtins.toJSON
            (pkgs.writeText "packages.json")
          ];

          updatePackages = pkgs.writeShellApplication {
            name = "update-packages";
            runtimeInputs = [ ];
            text = ''
              ${pkgs.python3.interpreter} ${nixpkgs.outPath}/maintainers/scripts/update.py ${packagesJson} "$@"
            '';
          };

        in
        {
          update-packages = {
            type = "app";
            program = lib.getExe updatePackages;
          };
        }
      );

      packages = forAllSystems (
        pkgs:
        lib.attrsets.filterAttrs (
          _: lib.attrsets.isDerivation
        ) self.legacyPackages.${pkgs.stdenv.hostPlatform.system}
      );

      devShells = forAllSystems (
        pkgs:
        let
          checks = self.checks.${pkgs.stdenv.hostPlatform.system};

          inherit (checks) check-format-and-lint;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ check-format-and-lint ];

            nativeBuildInputs = with pkgs; [
              # LSPs
              nixd
              yaml-language-server
              vscode-langservers-extracted

              # Tools
              nix-update
            ];
          };
        }
      );

      legacyPackages = forAllSystems (
        pkgs:
        import ./default.nix {
          inherit pkgs lib;
          flake = true;
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

      checks = forAllSystems (
        pkgs:
        let
          derivations' = derivations.${pkgs.stdenv.hostPlatform.system};
          shells' = self.devShells.${pkgs.stdenv.hostPlatform.system};

          packages = lib.trivial.pipe derivations' [
            (builtins.map (
              { path, package }:
              let
                cleanedPath = builtins.replaceStrings [ "." ] [ "_" ] path;

              in
              {
                name = "package_${cleanedPath}";
                value = package;
              }
            ))
            builtins.listToAttrs
          ];
          shells = lib.attrsets.mapAttrs' (n: v: lib.attrsets.nameValuePair "shell_${n}" v) shells';

          check-format-and-lint =
            pkgs.runCommand "check-format-and-lint"
              {
                nativeBuildInputs = with pkgs; [
                  actionlint
                  deadnix
                  nixfmt-rfc-style
                  statix
                  typos
                ];
              }
              ''
                cd ${self}

                echo "running typos..."
                typos --hidden

                echo "running actionlint..."
                actionlint ./.github/workflows/*

                echo "running nixfmt..."
                nixfmt --check .

                echo "running deadnix...."
                deadnix -- --check .

                echo "running statix..."
                statix check .

                touch $out
              '';
        in
        { inherit check-format-and-lint; } // shells // packages
      );
    };
}

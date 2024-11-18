{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  inherit (lib.attrsets) recursiveUpdate;

  pkgsLib = recursiveUpdate pkgs {
    lib.maintainers = import ./maintainers/maintainer-list.nix;
  };

  packages = lib.packagesFromDirectoryRecursive {
    directory = ./pkgs;
    callPackage = lib.callPackageWith pkgsLib;
  };
in
packages

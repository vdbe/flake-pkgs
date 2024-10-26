{
  pkgs,
  lib ? pkgs.lib,

  includeLib ? false,
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
if includeLib then (recursiveUpdate packages { inherit (pkgsLib) lib; }) else packages

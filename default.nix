{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  flake ? false,
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
if flake then packages else (recursiveUpdate packages { inherit (pkgsLib) lib; })

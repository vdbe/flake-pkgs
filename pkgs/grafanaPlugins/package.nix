{ newScope, pkgs }:
let
  callPackage = newScope (pkgs // pkgs.grafanaPlugins // plugins);
  plugins = import ./plugins.nix { inherit callPackage; };
in
plugins

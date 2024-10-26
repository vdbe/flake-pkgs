{
  pkgs,
  newScope,
  grafanaPlugins,
}:
let
  callPackage = newScope (pkgs // grafanaPlugins // plugins);

  plugins = import ./plugins.nix { inherit callPackage; };
in
plugins

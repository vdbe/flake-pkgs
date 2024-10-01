{
  nixpkgsPath ? <nixpkgs>,
  include-overlays ? false,
  ...
}@args:
let
  overlays =
    (
      if !include-overlays then
        [ ]
      else if include-overlays then
        # Let Nixpkgs include overlays impurely.
        throw "Euhm no idea what to do here" { }
      else
        include-overlays
    )
    ++ [
      # Add custom pkg's
      (_: prev: prev.lib.attrsets.recursiveUpdate prev (import ../../default.nix { pkgs = prev; }))
      # Add custom maintainer list
      (
        _: prev:
        prev.lib.attrsets.recursiveUpdate prev {
          lib.maintainers = import ../maintainer-list.nix;
        }
      )
    ];
in
import "${nixpkgsPath}/maintainers/scripts/update.nix" (args // { include-overlays = overlays; })

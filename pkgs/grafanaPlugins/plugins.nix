{ callPackage }:
{
  grafanaPlugin = callPackage ./grafana-plugin.nix { };

  grafana-lokiexplore-app = callPackage ./grafana-lokiexplore-app { };
}

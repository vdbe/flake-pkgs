{ callPackage }:
{
  grafanaPlugin = callPackage ./grafana-plugin.nix { };

  camptocamp-prometheus-alertmanager-datasource =
    callPackage ./camptocamp-prometheus-alertmanager-datasource
      { };
}

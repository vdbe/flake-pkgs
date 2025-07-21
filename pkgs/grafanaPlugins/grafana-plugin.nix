{ grafanaPlugins, pkgs }:
let
  upstreamUpdateScript = "${pkgs.path}/pkgs/servers/monitoring/grafana/plugins/update-grafana-plugin.sh";
in
{
  pname,
  passthru ? { },
  ...
}@args:
grafanaPlugins.grafanaPlugin (
  args
  // {
    passthru = {
      updateScript = [
        ./update-grafana-plugin.sh
        upstreamUpdateScript
        pname
      ];
    }
    // passthru;
  }
)

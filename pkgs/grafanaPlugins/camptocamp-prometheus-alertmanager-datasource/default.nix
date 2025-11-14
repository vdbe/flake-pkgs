{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "camptocamp-prometheus-alertmanager-datasource";
  version = "2.3.1";
  zipHash = "sha256-C4PNG/qRPjfZwjOIQ2aF915GbxvUE9h3H4uyi4xt84g=";
  meta = {
    license = lib.licenses.asl20;
    description = "Log explorer plugin for Grafana";
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers."vdbe/custom" ];
  };
})

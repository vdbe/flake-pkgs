{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "camptocamp-prometheus-alertmanager-datasource";
  version = "2.1.0";
  zipHash = "sha256-6FAknAxf252riwNgCj4V4qEYnD6b39kisIZOlGUjggU=";
  meta = {
    license = lib.licenses.asl20;
    description = "Log explorer plugin for Grafana";
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers."vdbe/custom" ];
  };
})

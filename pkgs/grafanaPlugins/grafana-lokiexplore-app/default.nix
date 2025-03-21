{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.9";
  zipHash = "sha256-BuzcJVS6McLR0UYzCiqm2XOniZ7e2PNXf9fX9iRVXSE=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

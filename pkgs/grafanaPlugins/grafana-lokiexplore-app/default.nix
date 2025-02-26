{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.8";
  zipHash = "sha256-f7/6qvSoBEaxAj81WyE4MQPQFQe6TWc2P7mbsqRl2kw=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

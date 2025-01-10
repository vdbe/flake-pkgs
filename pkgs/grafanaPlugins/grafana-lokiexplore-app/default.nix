{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.5";
  zipHash = "sha256-6ZvN2aTpU4czy6XjP09GGlQmXSbUqdf/iuWhVKKQ91Q=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

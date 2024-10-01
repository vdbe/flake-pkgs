{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.0";
  zipHash = "sha256-nyFkIiIpdpab0P6Yecy1S+4EX1Z1f8Ss9NNwSIwcEk4=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

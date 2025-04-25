{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.13";
  zipHash = "sha256-oTiwvkKiKpeI7MUxyaRuxXot4UhMeSvuJh0N1VIfA5Q=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

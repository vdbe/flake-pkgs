{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.1";
  zipHash = "sha256-ZgyzT7ayFGFd5v7kkFtoNeF1M3HRIxgOd/dFRZ3UHwo=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

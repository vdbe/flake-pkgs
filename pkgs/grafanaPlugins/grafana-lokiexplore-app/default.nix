{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.6";
  zipHash = "sha256-8XQV3wOSYgZwvnjZh4DwsiSBrkCVounGSxg3EVTN5mE=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

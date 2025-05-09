{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.15";
  zipHash = "sha256-Qxkm4l+4DC5HxaiZ85i46Xih1k97nditcEEwvemA5P0=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

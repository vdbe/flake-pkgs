{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.4";
  zipHash = "sha256-WoEZHTjad3betYvpe2HvHDL9QtLcISzjsLUrqH+r/cg=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

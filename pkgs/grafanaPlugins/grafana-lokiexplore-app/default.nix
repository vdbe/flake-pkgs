{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.17";
  zipHash = "sha256-XAMxeeFTeC/x2ZqlVk8QQKPwBMnAXIgr7S+NEVcVtOI=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

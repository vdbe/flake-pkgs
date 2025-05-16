{ grafanaPlugin, lib }:

(grafanaPlugin {
  pname = "grafana-lokiexplore-app";
  version = "1.0.16";
  zipHash = "sha256-v2DckijdmkJKYLE/MRDafKeg5svai9fqbIozTKDczUo=";
  meta = with lib; {
    description = "Log explorer plugin for Grafana";
    platforms = platforms.unix;
    maintainers = [ maintainers."vdbe/custom" ];
  };
})

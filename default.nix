{
  system ? builtins.currentSystem,
  ...
}:

let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  root = lock.nodes.${lock.root};
  inherit (lock.nodes.${root.inputs.flake-compat}.locked)
    owner
    repo
    rev
    narHash
    ;

  flake-compat = fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };

  flake = import flake-compat {
    inherit system;
    # hack to skip fetchGit when evaluating impurely and get original paths
    src = {
      outPath = ./.;
    };
  };

  self = flake.defaultNix;

in
self.legacyPackages.${system}

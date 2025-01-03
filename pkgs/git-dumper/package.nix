{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,

}:
python3Packages.buildPythonApplication rec {
  pname = "git-dumper";
  version = "1.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "arthaud";
    repo = "git-dumper";
    rev = version;
    hash = "sha256-XU+6Od+mC8AV+w7sd8JaMB2Lc81ekeDLDiGGNu6bU0A=";
  };

  build-system = [ python3Packages.setuptools ];

  propagatedBuildInputs = [
    python3Packages.pysocks
    python3Packages.requests
    python3Packages.beautifulsoup4
    python3Packages.dulwich
    python3Packages.requests-pkcs12
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A tool to dump a git repository from a website ";
    homepage = "https://github.com/arthaud/git-dumper";
    license = lib.licenses.mit;
  };
}

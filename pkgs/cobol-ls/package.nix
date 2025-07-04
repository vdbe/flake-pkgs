{
  lib,
  maven,
  makeWrapper,
  jre,
  fetchFromGitHub,
  nix-update-script,
}:
maven.buildMavenPackage rec {
  pname = "cobol-ls";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "eclipse-che4z";
    repo = "che-che4z-lsp-for-cobol";
    rev = version;
    hash = "sha256-6bImy5ySDDeOxgSWvyCXkCIPrGncX3YOlaerN5gbY0k=";
  };
  nativeBuildInputs = [ makeWrapper ];

  mvnHash = "sha256-IOmKUbsnB3ulyuO5Rl23HRqfXtvJiCIwa9ZH3HKCqFw=";

  sourceRoot = "${src.name}/server";

  installPhase = ''
    mkdir -p $out/bin \
      $out/share/cobol-ls/ \
      $out/share/cobol-ls/dialects

    install -Dm644 engine/target/server.jar $out/share/cobol-ls/
    install -Dm644 dialect-daco/target/dialect-daco.jar $out/share/cobol-ls/dialects/
    install -Dm644 dialect-idms/target/dialect-idms.jar $out/share/cobol-ls/dialects/

    # Copied from https://github.com/eclipse-che4z/che-che4z-lsp-for-cobol/blob/e00aaad3cb4993fd6ff3c038886aa44564b9acc7/clients/cobol-lsp-vscode-extension/src/services/LanguageClientService.ts#L183-L194
    makeWrapper ${jre}/bin/java $out/bin/cobol-language-support \
          --add-flags "-Dline.separator=\r\n" \
          --add-flags "-Ddialect.path=$out/share/cobol-ls/dialects/" \
          --add-flags "-Xmx768M" \
          --add-flags "-jar $out/share/cobol-ls/server.jar" \
          --add-flags "pipeEnabled"
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "COBOL Language Support";
    mainProgram = "cobol-language-support";
    homepage = "https://github.com/eclipse-che4z/che-che4z-lsp-for-cobol";
    license = lib.licenses.epl20;
  };
}

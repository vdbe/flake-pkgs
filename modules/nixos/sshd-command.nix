{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) types;
  commandSuffix = "ssh/scripts/sshd-command";

  templateOpts =
    { name, config, ... }:
    {
      options = {
        sshd-command = {
          version = lib.mkOption {
            type = types.str;
            default = cfg.package.version;
          };
          command = lib.mkOption {
            type = types.enum [
              "principals"
              "keys"
            ];
          };
          tokens = lib.mkOption {
            type = types.listOf (
              types.enum [
                "%C"
                "%D"
                "%F"
                "%f"
                "%h"
                "%i"
                "%K"
                "%k"
                "%S"
                "%T"
                "%t"
                "%U"
                "%u"
              ]
            );
            default = [ ];
          };
          hostname = lib.mkOption {
            type = types.bool;
            default = true;
          };
          complete_user = lib.mkOption {
            type = types.bool;
            default = true;
          };
        };

        extraFrontMatter = lib.mkOption {
          inherit (pkgs.formats.yaml { }) type;
          default = { };
        };

        tera = lib.mkOption {
          type = types.lines;
        };
        path = lib.mkOption {
          type = types.pathInStore;
          readOnly = true;
          internal = true;
        };
        configLine = lib.mkOption {
          type = types.str;
          readOnly = true;
          internal = true;
        };
      };

      config =
        let
          front_matter =
            let
              m = lib.attrsets.recursiveUpdate {
                sshd_command = config.sshd-command;
              } config.extraFrontMatter;

            in
            lib.attrsets.recursiveUpdate m {
              sshd_command.tokens = lib.strings.concatStringsSep " " m.sshd_command.tokens;
            };

        in
        {
          path = pkgs.writeText "${name}.tera" ''
            ---
            ${lib.generators.toYAML { } front_matter}
            ---
            ${config.tera}
          '';

          configLine = lib.strings.concatStringsSep " " [
            (
              if config.sshd-command.command == "principals" then
                "AuthorizedPrincipalsCommand"
              else if config.sshd-command.command == "keys" then
                "AuthorizedKeysCommand"
              else
                throw "Should never get here"
            )
            "/etc/${cfg.packagePath}"
            "--"
            config.path
            (lib.strings.concatStringsSep " " config.sshd-command.tokens)
          ];
        };

    };

  cfg = config.services.openssh.sshd-command;
in
{
  options.services.openssh.sshd-command = {
    enable = lib.mkEnableOption "sshd-command";
    package = lib.mkOption {
      type = lib.types.package;
      description = "The sshd-command package to use.";

      default = pkgs.callPackage ../../pkgs/sshd-command/package.nix { };
    };
    packagePath = lib.mkOption {
      type = types.str;
      default = "${commandSuffix}";
      description = "path where `package` is placed under /etc";
    };
    templates = lib.mkOption {
      default = { };
      type = types.attrsOf (types.submodule templateOpts);
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc.${cfg.packagePath} = {
      mode = "0555";
      source = lib.meta.getExe cfg.package;
    };

    services.openssh.extraConfig = lib.mkIf (cfg.templates != { }) (
      lib.strings.concatLines (lib.attrsets.mapAttrsToList (_: v: v.configLine) cfg.templates)
    );

    system.checks = lib.mapAttrsToList (
      template_name: template:
      pkgs.runCommand "check-sshd-command-template-${template_name}"
        {
          nativeBuildInputs = [
            cfg.package
          ];
        }
        ''
          sshd-command --check ${template.path}
          touch $out
        ''
    ) cfg.templates;
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    pipe
    mapAttrsToList
    concatStringsSep
    mkIf
    ;
in
{
  options.services.vertd = {
    enable = mkEnableOption "Enable vertd";
    package = mkOption {
      type = types.package;
      default = (pkgs.callPackage ./package.nix { });
      description = "Package of vertd to run";
    };
    options = {
      WEBHOOK_URL = mkOption {
        type = types.str;
        default = "";
        description = "If set, vertd will attempt to notify you via a discord webhook when a video fails to convert.";
      };
      WEBHOOK_PINGS = mkOption {
        type = types.str;
        default = "<@&role_id> <@user_id>";
        description = "Webhook pings -- these will be formatted into the main message";
      };
      ADMIN_PASSWORD = mkOption {
        type = types.str;
        default = "";
        description = "Admin password for kept videos.";
      };
      PUBLIC_URL = mkOption {
        type = types.str;
        default = "";
        description = "Used for kept video access";
      };
    };
  };
  config.systemd.services.vertd = mkIf config.services.vertd.enable {
    name = "vertd.service";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    description = "vertd - media conversion services";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.ffmpeg ];
    serviceConfig = {
      User = "vertd";
      Group = "vertd";
      DynamicUser = true;
      Restart = "on-failure";
      EnvironmentFile = pipe config.services.vertd.options [
        (mapAttrsToList (k: v: "${k}=${v}"))
        (concatStringsSep "\n")
        (pkgs.writeText "vert.env")
      ];
      ExecStart = lib.getExe' config.services.vertd.package "vertd";
      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectSystem = "strict";

      CacheDirectory = "vertd";
      CacheDirectoryMode = 0700;
      WorkingDirectory = "/var/cache/vertd";
      ReadWritePaths = "/var/cache/vertd";
      NoExecPaths = "/var/cache/vertd";
    };
  };
}

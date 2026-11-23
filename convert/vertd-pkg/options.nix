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
  cfg = config.services.vertd;
in
{
  options.services.vertd = {
    enable = mkEnableOption "Enable vertd";
    package = mkOption {
      type = types.package;
      default = (pkgs.callPackage ./package.nix { });
      description = "Package of vertd to run";
    };
    port = mkOption {
      type = types.port;
      default = 24153;
      description = "Port for vertd to listen on";
    };
    options = {
      WEBHOOK_URL = mkOption {
        type = types.str;
        default = "";
        description = "If set, vertd will attempt to notify you via a discord webhook when a video fails to convert.";
      };
      WEBHOOK_PINGS = mkOption {
        type = types.str;
        example = "<@&role_id> <@user_id>";
        default = "";
        description = "Webhook pings -- these will be formatted into the main message";
      };
      ADMIN_PASSWORD = mkOption {
        type = types.str;
        default = "";
        example = "supersecret";
        description = "Admin password for kept videos.";
      };
      PUBLIC_URL = mkOption {
        type = types.str;
        default = "";
        description = "Used for kept video access";
      };
      CORS_ORIGINS = mkOption {
        type = types.str;
        default = "*";
        description = "Allows CORS origins for vertd. Can either be \"*\" or comma separated origins: \"https://origin1.com,https://origin2.com\".";
      };
    };
  };
  config.systemd.services.vertd = mkIf cfg.enable {
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
      EnvironmentFile = pipe (cfg.options // { PORT = toString cfg.port; }) [
        (mapAttrsToList (k: v: "${k}=${v}"))
        (concatStringsSep "\n")
        (pkgs.writeText "vert.env")
      ];
      ExecStart = lib.getExe cfg.package;
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

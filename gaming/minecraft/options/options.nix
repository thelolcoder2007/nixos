{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.services.minecraft-server;
  opsFile = pkgs.writeText "ops.json" (builtins.toJSON cfg.ops);
in
{
  options.services.minecraft-server.ops =
    let
      minecraftUUID =
        lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
        // {
          description = "Minecraft UUID";
        };
    in
    mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "name of the use to give op, defaults to the attribute name.";
          };
          level = mkOption {
            type = types.enum [
              1
              2
              3
              4
            ];
            default = 4;
            description = "op-level to give the user";
          };
          uuid = mkOption {
            type = minecraftUUID;
            description = "Minecraft uuid of the operator. You can use https://mcuuid.net/ to get a Minecraft UUID for a username";
          };
          bypassesPlayerLimit = mkOption {
            type = types.bool;
            default = false;
            description = "sets the bypassesplayerlimit";
          };
        };
      });
      default = [ ];
      description = ''
        Operators. Only has an effect when
        {option}`services.minecraft-server.declarative` is
        `true`.
      '';
      example = lib.literalExpression ''
        [
          {
            name = "username1";
            uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            level = 3;
            bypassesPlayerLimit = true;
          }
        };
      '';
    };
  config = lib.mkIf cfg.enable {
    systemd.services.minecraft-server.preStart =
      if cfg.declarative then lib.mkAfter "ln -sf ${opsFile} ops.json" else lib.mkDefault "";
  };
}

# This file has been adapted from https://github.com/NixOS/nixpkgs/pull/327137 (by ilovethensa)
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
    mkIf
    ;
  cfg = config.services.mindustry-server;
in
{
  options = {
    services.mindustry-server = {
      enable = mkEnableOption "Mindustry server";

      openFirewall = mkEnableOption "Open ports in the firewall for the mindustry server";
      package = mkOption {
        type = types.package;
        default = pkgs.mindustry-server;
        description = "Mindustry server package to run";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mindustry-server = {
      description = "Mindustry server";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.bash} -c \"cd /var/lib/mindustry && exec ${lib.getExe' cfg.package "mindustry-server"} host\"";
        DynamicUser = true;
        RuntimeDirectory = "/var/lib/mindustry";
        StateDirectory = "mindustry";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 6567 ];
      allowedUDPPorts = [ 6567 ];
    };
  };
}

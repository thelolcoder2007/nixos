{
  config,
  lib,
  pkgs,
  ...
}:
let
  script = pkgs.writeShellScript "update-roa.sh" ''
    mkdir -p /etc/bird/
    ${lib.getExe pkgs.curl} -sfSLR {-o,-z}/etc/bird/roa_dn42_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf
    ${lib.getExe pkgs.curl} -sfSLR {-o,-z}/etc/bird/roa_dn42.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf
    ${lib.getExe' config.services.bird.package "birdc"} c
  '';
in
{
  systemd = {
    timers.dn42-roa = {
      description = "Trigger a ROA table update";

      timerConfig = {
        OnBootSec = "5m";
        OnUnitInactiveSec = "1h";
        Unit = "dn42-roa.service";
      };
      wantedBy = [ "timers.target" ];
      before = [ "bird.service" ];
    };

    services.dn42-roa = {
      after = [ "network.target" ];
      description = "DN42 ROA Update";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
      };
    };
  };
}

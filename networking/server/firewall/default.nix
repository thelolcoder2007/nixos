{ config, lib, ... }:

{
  networking.firewall = {
    logRefusedConnections = false;
    logRefusedUnicastsOnly = false;
    logRefusedPackets = true;
    extraInputRules =
      let
        ipv4addr = builtins.filter (ip: lib.hasInfix "." ip) (
          lib.splitString "," config.services.zabbixAgent.server
        );
        ipv6addr = builtins.filter (ip: lib.hasInfix ":" ip) (
          lib.splitString "," config.services.zabbixAgent.server
        );
      in
      ''
        ip saddr { ${builtins.concatStringsSep ", " ipv4addr} } tcp dport 10050 accept comment "monitoring from monitoring servers";
        ip6 saddr { ${builtins.concatStringsSep ", " ipv6addr} } tcp dport 10050 accept comment "monitoring from monitoring servers";
      '';
  };
}

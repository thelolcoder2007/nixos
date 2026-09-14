{
  config,
  inputs,
  lib,
  pkgs,
  serverHost ? "hera",
  ...
}:

let
  zabbixUsername = "zabbix";
in
assert (builtins.elem serverHost (lib.attrNames inputs.self.nixosConfiguratons));
{
  imports = [
    ../database/postgres.nix
    ../networking/server/HTTP/defaults.nix
    ../networking/server/HTTP/options.nix
  ];

  services = {
    zabbixWeb = {
      enable = true;
      frontend = "nginx";
      hostname = config.networking.fqdnOrHostName;
      database = {
        socket = "/var/run/postgresql/postgresql.sock";
        type = "pgsql";
        name = "zabbix";
        user = zabbixUsername;
      };
      package = pkgs.zabbix74.web;
      nginx.virtualHost = {
        default = true; # There should be no other NGINX virtualhosts on this host, otherwise monitoring is dependent on other hosts which should not be
        listen = lib.mkForce [
          {
            addr = "0.0.0.0";
            port = 8080;
          }
          {
            addr = "[::]";
            port = 8080;
          }
        ];
      };
    };
    zabbixProxy.enable = true;
    zabbixProxy.package = pkgs.zabbix74.proxy-pgsql;
    server =
      assert inputs.nixosConfiguration.${serverHost}.config.services.zabbixServer.enable; # Ensure Zabbix server is running on the host the proxy points towards
      (builtins.elemAt
        inputs.nixosConfiguration.${serverHost}.config.networking.interfaces.ens192.ipv4.addresses
        0
      ).address;
    postgresql = {
      ensureUsers = [
        {
          name = zabbixUsername;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        zabbixUsername
      ];
    };
  };
  x.nginx.virtualHosts.${config.networking.fqdnOrHostName}.snakeoilHost = true;
}

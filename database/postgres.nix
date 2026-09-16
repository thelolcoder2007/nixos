{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../base/sops.nix
  ];
  sops.secrets."database_monitor_password".restartUnits = [
    "postgresql.service"
  ];
  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "zabbix-monitor-setup.sql" ''
      CREATE USER zbx_monitor WITH PASSWORD $(${config.sops.secrets."database_monitor_password".path});
      GRANT pg_monitor TO zbx_monitor;
    '';

    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      local   all             postgres                                peer
      local   all             zabbix                                  trust
      host    all             zabbix          127.0.0.1/32            md5
    '';
  };
  services.zabbixAgent = {

    # Monitoring Postgres server
    extraPackages = with pkgs; [
      zabbix-agent2-plugin-postgresql
    ];
    settings = {
      "Plugins.PostgreSQL.System.Path" = lib.getExe pkgs.zabbix-agent2-plugin-postgresql;

      "Plugins.PostgreSQL.Sessions.postgres.Uri" = "tcp://localhost:5432";
      "Plugins.PostgreSQL.Sessions.postgres.User" = "zabbix";
      "Plugins.PostgreSQL.Sessions.postgres.Password" = "$(cat ${
        config.sops.secrets."database_monitor_password".path
      })";
      "Plugins.PostgreSQL.Sessions.postgres.Database" = "postgres";
    };
  };
}

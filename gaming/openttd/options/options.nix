{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.openttd;
  inherit (lib) mkEnableOption mkOption types;
  tomlFormat = pkgs.formats.toml { };
  default_cfg = ''
    [network]
    server_name = "My OpenTTD Server"
    server_advertise = true        # list on the public server browser
    lan_internet = 1               # 0 = LAN, 1 = Internet
    max_clients = 25
    max_companies = 15
    max_spectators = 15
    server_password = ""           # empty = no join password
    rcon_password = "change-me"    # remote console access
    admin_password = "change-me-too" # admin port (3977) access
    pause_on_join = true
    min_active_clients = 0         # 0 = never auto-pause
    autoclean_companies = true
    autoclean_unprotected = 12     # months of inactivity before removal
    autoclean_protected = 36
    autoclean_novehicles = 0
    restart_game_year = 0          # 0 = never auto-restart

    [game_creation]
    landscape = "temperate"        # temperate, arctic, tropic, toyland
    map_x = 9                      # 2^9 = 512 tiles
    map_y = 9
    starting_year = 1950
    land_generator = 1             # 1 = TerraGenesis
    terrain_type = 1
    quantity_sea_lakes = 1
    tgen_smoothness = 1
    variety = 0

    [difficulty]
    max_no_competitors = 0         # AI opponents
    number_towns = 2
    number_industries = 2
    vehicle_breakdowns = 1
    subsidy_multiplier = 2
    construction_cost = 0
    vehicle_costs = 0
    max_loan = 300000
    initial_interest = 2
    infinite_money = false

    [gui]
    autosave = "monthly"           # off, monthly, quarterly, half year, yearly
    autosave_on_exit = true
    keep_all_autosave = false

    [misc]
    display_opt = 0
  '';
in
{
  options.services.openttd = {
    enable = mkEnableOption "Enable OpenTTD dedicated server";
    package = mkOption {
      type = types.package;
      default = pkgs.openttd;
      description = "OpenTTD package to use for the dedicated server";
    };
    port = mkOption {
      type = types.port;
      default = 3979;
      description = "Port for OpenTTD dedicated server to use. This sets settings.network.server_port.";
    };
    adminPort = mkOption {
      type = types.port;
      default = 3977;
      description = "Port for remote management of OpenTTD dedicated server. This sets settings.network.server_admin_port.";
    };
    configFile = mkOption {
      type = types.nullOr (types.pathWith { inStore = true; });
      default = null;
      description = "Configuration file. If config file is not null, the options settings, port and adminPort have no use.";
    };
    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Config to be put into config file. If configFile is not null, this has no use.";
    };
  };
  config =
    let
      configFile =
        if cfg.configFile != null then
          cfg.configFile
        else
          pkgs.writeText "openttd.cfg" (
            lib.generators.toINI { } (
              lib.recursiveUpdate (lib.recursiveUpdate (fromTOML default_cfg) cfg.settings) {
                network = {
                  server_port = cfg.port;
                  server_admin_port = cfg.adminPort;
                };
              }
            )
          );
    in
    lib.mkIf cfg.enable {
      systemd.services."openttd-ds" = {
        after = [ "network.target" ];
        description = "OpenTTD Dedicated server";
        script = "${lib.getExe cfg.package} -D -x -c ${lib.toString configFile}";
        environment = {
          HOME = "/var/lib/openttd";
          XDG_DATA_HOME = "/var/lib/openttd";
        };
        serviceConfig = {
          DynamicUser = true;
          LogsDirectory = "openttd";
          MemoryDenyWriteExecute = false;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";
          RestartSec = "10s";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "openttd";
          WorkingDirectory = "/var/lib/openttd";
        };
        wantedBy = [ "multi-user.target" ];
      };
      networking.firewall = {
        allowedTCPPorts = [
          cfg.port
          cfg.adminPort
        ];
        allowedUDPPorts = [
          cfg.port
          cfg.adminPort
        ];
      };
    };
}

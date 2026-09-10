{ config, ... }:

{
  imports = [
    ../base/sops.nix
  ];
  sops.secrets."lk-jwt_key" = {
    restartUnits = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
  };
  systemd.services.lk-jwt-service.environment = {
    "LIVEKIT_FULL_ACCESS_HOMESERVERS" = "*";
  };
  services = {
    lk-jwt-service = {
      enable = true;
      livekitUrl = "wss://livekit.dapperepoging.nl/livekit/sfu";
      keyFile = config.sops.secrets.lk-jwt_key.path;
    };
    livekit = {
      enable = true;
      keyFile = config.sops.secrets.lk-jwt_key.path;
      settings = {
        port = 7880;
        bind_addresses = [
          "0.0.0.0"
          "[::]"
        ];
        rtc = {
          tcp_port = 7881;
          port_range_start = 50100;
          port_range_end = 50200;
          use_external_ip = false;
          enable_loopback_candidate = false;
        };
        turn.enabled = false;
      };
    };
  };
}

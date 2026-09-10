{
  config,
  ...
}:

{
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "dapperepoging.nl";
        port = [ 6963 ];
        address = [
          "::"
          "0.0.0.0"
        ];
        new_user_displayname_suffix = "";
        query_all_nameservers = false;
        ip_lookup_strategy = 4;
        max_request_size = 2147483648;
        suspend_on_register = true; # Extra safety
        trusted_servers = [
          # keep-sorted start
          "iapc.nl"
          "tchncs.de"
          "unredacted.org"
          "utwente.io"
          # keep-sorted end
          "matrix.org"
        ];
        log_to_journald = true;

        allow_outgoing_presence = true;
        url_preview_domain_contains_allowlist = [ "*" ]; # Allow previews
        allow_legacy_media = false;
        deprioritize_joins_through_servers = [
          "matrix.org" # Because matrix.org kinda sucks in the speed department
        ];
        tls.dual_protocol = true; # I'm not sending HTTPS traffic to my c10y, so enable HTTP requests please
        well_known = {
          client = "https://matrix.dapperepoging.nl";
          server = "matrix.dapperepoging.nl:443";
        };
        matrix_rtc.foci = [
          {
            type = "livekit";
            livekit_service_url = "https://livekit.dapperepoging.nl/livekit/jwt";
          }
        ];
      };
    };
  };
  systemd.services.nginx.serviceConfig.SupplementaryGroups = [
    config.services.matrix-continuwuity.group
  ];
  services.nginx = {
    virtualHosts = {
      "dapperepoging.nl".locations."/.well-known/matrix".proxyPass = "http://localhost:6963";
      "matrix.dapperepoging.nl".locations."/".proxyPass = "http://localhost:6963";
    };
  };
}

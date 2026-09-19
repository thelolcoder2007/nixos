{
  services.nginx = {
    enable = true;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Add Nginx monitoring page
    virtualHosts."localhost" = {
      listenAddresses = [
        "127.0.0.1"
        "[::1]"
      ];
      locations."/basic_status".extraConfig = ''
        stub_status;
        server_tokens on;
        allow 127.0.0.1;
        allow ::1;
        deny all;
      '';
    };
  };
}

{
  imports = [
    ../HTTP/defaults.nix
    ../HTTP/options.nix
  ];
  x.nginx.virtualHost."certs.16.dapperepoging.nl".localAcmeHost = true;
  services.nginx = {
    upstreams."CERTS-UPSTREAM".servers = {
      # "127.0.0.1:7127" = {}; # STEP-CA does not support this
      "[::1]:7217" = { };
    };
    virtualHosts."certs.16.dapperepoging.nl".proxyPass = "http://CERTS-UPSTREAM";
  };
}

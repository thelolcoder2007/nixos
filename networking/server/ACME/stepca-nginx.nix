{ ... }:
{
  imports = [
    ../HTTP/defaults.nix
  ];
  services.nginx.virtualHosts."certs.16.dapperepoging.nl".locations = {
    "= /root.crt".alias = "/var/www/html/ca.crt";
    "= /intermediate.der".alias = "/var/www/html/intermediate.der";
    "/".return = "302 https://$host$request_uri";
  };
}

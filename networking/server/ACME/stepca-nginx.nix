{ ... }:
{
  imports = [
    ../HTTP/defaults.nix
  ];
  services.nginx.virtualHosts."certs.16.dapperepoging.nl".locations = {
    "= /root.crt".alias = "/var/www/html/ca.crt";
    "/".return = "302 https://$host$request_uri";
  };
  networking.firewall.allowedTCPPorts = [ 80 ];
}

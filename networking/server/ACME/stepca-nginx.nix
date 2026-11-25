{ ... }:
{
  imports = [
    ../HTTP/defaults.nix
  ];
  services.nginx.virtualHosts."certs.16.dapperepoging.nl".locations."/".return =
    "302 https://$host$request_uri";
  # NGINX does not listen on port 443, step-ca does that. This is just a HTTP -> HTTPS redirect
}

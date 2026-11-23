let
  url = "vertd.16.dapperepoging.nl";
in
{
  imports = [
    ./vertd-pkg/options.nix
    ../networking/server/HTTP/defaults.nix
    ../networking/server/HTTP/options.nix
  ];
  services.vertd = {
    enable = true;
    options = {
      PUBLIC_URL = url;
      CORS_ORIGINS = "https://vert.16.dapperepoging.nl";
    };
  };

  services.nginx.virtualHosts.${url}.locations."/".proxyPass = "http://127.0.0.1:24153";
  x.nginx.virtualHosts.${url}.localAcmeHost = true;
}

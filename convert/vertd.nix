{
  imports = [
    ./vertd-pkg/options.nix
  ];
  services.vertd.enable = true;

  services.nginx = {
    enable = true;
    virtualHosts."vertd.dapperepoging.nl".locations."/".proxyPass = "http://127.0.0.1:24153";
  };
  x.nginx.virtualHosts."vertd.dapperepoging.nl".snakeoilHost = true;
}

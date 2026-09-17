let
  mainIface = "ens192";
in
{
  _module.args = {
    inherit mainIface;
  };
  imports =
    let
      staticConf = {
        hostName = "hera";
        domain = "16.dapperepoging.nl";
        iface = mainIface;
        ipv4Address = "10.0.116.8";
        ipv6Address = "2a07:54c1:4932:116::8";
        defaultGateway = "10.0.116.1";
        defaultGateway6 = "fe80::c1c0";
      };
    in
    [
      # keep-sorted start
      (import ../networking/client/static.nix { conf = staticConf; })
      ../base/base.nix
      ../monitoring/zabbix-agent.nix
      ../monitoring/zabbix-server.nix
      ../networking/client/resolv.conf.nix
      ../networking/client/ssh.nix
      ../networking/client/tailscale.nix
      # keep-sorted end
    ];
}

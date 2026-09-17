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
        hostName = "hermes";
        domain = "16.dapperepoging.nl";
        iface = mainIface;
        ipv4Address = "10.0.116.6";
        ipv4PrefixLength = 24;
        ipv6Address = "2a07:54c1:4932:116::6";
        ipv6PrefixLength = 64;
        defaultGateway = "10.0.116.1";
        defaultGateway6 = "fe80::c1c0";
      };
    in
    [
      # keep-sorted start
      (import ../networking/client/static.nix { conf = staticConf; })
      ../base/base.nix
      ../matrix-irc/continuwuity.nix
      ../matrix-irc/element-call.nix
      ../matrix-irc/element-chat.nix
      ../matrix-irc/fluffychat.nix
      ../matrix-irc/irssi.nix
      ../matrix-irc/livekit.nix
      ../matrix-irc/maubot.nix
      ../matrix-irc/sable.nix
      ../monitoring/zabbix-agent.nix
      ../networking/client/resolv.conf.nix
      ../networking/client/ssh.nix
      ../networking/client/tailscale.nix
      # keep-sorted end
    ];
}

{
  config,
  lib,
  pkgs,
  peer,
  ...
}:
let
  # peer = {
  #   asnum = "424242xxxx";
  #   clearnetEndpoint = "x.x.x.x";
  #   remotePort = xxxxx;
  #   name = "sopsName";
  #   localPort = xxxxx;
  #   publickey = "a-bunch-off-bullshit";
  #   dn42Endpoint-LL = "xxxx";
  #   optionalConfig = '''';
  # };
  ifacename = "dn42_" + peer.asnum;
in
{
  imports = [
    ../../../base/sops.nix
  ];
  sops.secrets."bgp-${peer.name}-privatekey" = {
    restartUnits = [
      "wireguard-${ifacename}-peer-${peer.asnum}.service"
      "wireguard-${ifacename}.service"
    ];
  };

  networking.firewall.allowedUDPPorts = [ peer.localPort ];
  networking.wireguard.interfaces.${ifacename} = {
    privateKeyFile = config.sops.secrets."bgp-${peer.name}-privatekey".path;
    allowedIPsAsRoutes = false;
    listenPort = peer.localPort;
    mtu = 1420;
    peers = [
      {
        publicKey = peer.publickey;
        allowedIPs = [
          # keep-sorted start
          "10.0.0.0/8"
          "172.20.0.0/14"
          "172.31.0.0/16"
          "fd00::/8"
          "fe80::${peer.dn42Endpoint-LL}/128"
          # keep-sorted end
        ];
        endpoint = "${peer.clearnetEndpoint}:${peer.remotePort}";
        name = peer.asnum;
      }
    ];

    postSetup = ''
      ${lib.getExe' pkgs.iproute2 "ip"} -6 addr add fe80::2/128 peer fe80::${peer.dn42Endpoint-LL}/128 dev ${ifacename}
    '';
  };

  services.bird.config = lib.mkAfter ''
    protocol bgp AS${peer.asnum}_v6 from dnpeers {
      enable extended messages on;
      bfd graceful;
      bfd {
          interval 10s;
      };
      ipv4 {
        extended next hop on;
        ${peer.optionalConfig or ""}
      };
      ipv6 {
        ${peer.optionalConfig or ""}
      };
      neighbor fe80::${peer.dn42Endpoint-LL}%${ifacename} as ${peer.asnum};
    }
  '';
}

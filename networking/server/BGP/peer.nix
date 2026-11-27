{
  config,
  lib,
  pkgs,
  peers,
  ...
}:
# peers = [{
#   asnum = "424242xxxx";
#   clearnetEndpoint = "x.x.x.x";
#   remotePort = xxxxx;
#   name = "sopsName";
#   localPort = xxxxx;
#   publickey = "a-bunch-off-bullshit";
#   dn42Endpoint-LL = "xxxx";
#   optionalConfig = '''';
# } {...} ];
{
  imports = [
    ../../../base/sops.nix
  ];
  sops.secrets = lib.genAttrs' peers (
    peer:
    lib.nameValuePair "bgp-${peer.name}-privatekey" {
      restartUnits = [
        "wireguard-dn42_${peer.asnum}-peer-${peer.asnum}.service"
        "wireguard-dn42_${peer.asnum}.service"
      ];
    }
  );

  networking.firewall.allowedUDPPorts = map (peer: peer.localPort) peers;
  networking.wireguard.interfaces = lib.genAttrs' peers (
    peer:
    lib.nameValuePair "dn42_${peer.asnum}" {
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
        ${lib.getExe' pkgs.iproute2 "ip"} -6 addr add fe80::2/128 peer fe80::${peer.dn42Endpoint-LL}/128 dev dn42_${peer.asnum}
      '';
    }
  );

  services.bird.config = lib.mkAfter (
    lib.concatMapStringsSep "\n" (peer: ''
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
        neighbor fe80::${peer.dn42Endpoint-LL}%dn42_${peer.asnum} as ${peer.asnum};
      }
    '') peers
  );
}

{
  pkgs,
  conf,
  ...
}:

{
  services.pdns-recursor = {
    enable = true;
    dns = {
      inherit (conf) address port;
      allowFrom = [
        # Localhost (obviously)
        "127.0.0.1"
        "::1/128"
        # Tailscale / CGNAT range
        "100.64.0.0/10"
        "fd7a:115c:a1e0::/48"
        # Local subnets
        "10.0.111.0/24"
        "10.0.116.0/24"
        "2a07:54c1:4932::/48"
        # DN42
        "172.23.99.224/27"
        "fda7:54c1:4932::/48"
      ];
    };
    settings = {
      outgoing = {
        source_address = conf.outgoingAddresses;
        dont_query = [
          # keep-sorted start
          "0.0.0.0/8" # Should never be a destination in the first place
          # "10.0.0.0/8" # RFC1918 address, used for Freifunk, ICVPN and PROD ranges
          "100.64.0.0/10" # RFC6598 address, used for CGNAT
          "127.0.0.1/8" # Loopback addresses, since I will not be asking myself for information
          "169.254.0.0/16" # IPv4 APIPA, not routable
          # "172.16.0.0/12" # RFC1918 address, used for DN42 (172.20.0.0/14) and ChaosVPN (172.31.0.0/16)
          "192.0.0.0/24" # Part of a IPv6-to-IPv4 translation prefix
          "192.0.2.0/24" # TEST-NET-1, documentation range
          "192.168.0.0/16" # RFC1918, we don't use it so there should be no server on this range
          "198.51.100.0/24" # TEST-NET-2, documentation range
          "203.0.113.0/24" # TEST-NET-3, documentation range
          "224.0.0.0/4" # IPv4 multicast
          "240.0.0.0/4" # IPv4 "reserved for future use"
          # keep-sorted end

          # keep-sorted start
          "100::/64" # RFC6666, "discard prefix". This is used when the traffic should be discarded
          "2001:db8::/32" # IPv6 documentation range
          "::/96" # Deprecated in favor of "::ffff:0:0/96", did the same thing
          "::ffff:0:0/96" # Represent IPv4 addresses in IPv6 format
          "fc00::/8" # Reserved ULA address space
          # "fd00::/8" # IPv6 ULA range, used for DN42, among other things
          "fe80::/10" # Link-local address
          "ff00::/8" # IPv6 multicast
          # keep-sorted end
        ];
      };
      recursor = {
        hint_file = pkgs.fetchurl {
          url = "https://www.internic.net/domain/named.root";
          sha256 = "sha256-IFmO9PPcHQkRGjECOV3aiLyHQR9d0jl08eMebAotTE0=";
        };
        lua_config_file = "";
        # forward_zones_recurse =
        #   let
        #     dn42Forwarders = [
        #       # keep-sorted start
        #       "172.20.1.254"
        #       "172.20.129.1"
        #       "172.20.132.105"
        #       "172.20.14.34"
        #       "172.22.108.54"
        #       "172.23.91.1"
        #       "fd00:913e:130::400"
        #       "fd42:4242:2189::1"
        #       "fd42:4242:2601:ac53::1"
        #       "fd42:5d71:219:0:216:3eff:fe1e:22d6"
        #       "fd86:bad:11b7:53::1"
        #       "fdcf:8538:9ad5:1111::2"
        #       # keep-sorted end
        #     ];
        #     clearnetForwarders = [
        #       # keep-sorted start
        #       "192.42.116.139"
        #       "192.42.116.39"
        #       "192.42.116.89"
        #       "192.42.116.9"
        #       "2001:67c:e60:c0c::53:1"
        #       "2001:67c:e60:c0c::53:2"
        #       "2001:67c:e60:c0c::53:3"
        #       "2001:67c:e60:c0c::53:4"
        #       # keep-sorted end
        #     ];
        #   in
        #   [
        #     {
        #       zone = ".";
        #       forwarders = clearnetForwarders;
        #     }
        #   ];
      };

      dnssec.validation = "process-no-validate";
    };
  };
}

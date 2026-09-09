{ inputs, ... }:

{
  services.dnsdist = {
    enable = true;
    extraConfig =
      # Unfortunately this is handwork for now
      ''
            	-- Who is allowed to query DNS on this forwarder?
            	setLocal('0.0.0.0:53')
             	addLocal('[::]:53')

              setAcl("10.0.116.0/24")
              addAcl("10.0.111.0/24")
              addAcl("2a07:54c1:4932::/48")

              addAcl("127.0.0.0/8")
              addAcl("::1/128")

              addAcl("100.64.0.0/10")
              addAcl("fd7a::115c:a1e0::/48")

              addAcl("172.23.99.224/27")
              addAcl("fda7:54c1:4932::/48")

            	-- Zeus is the leader of the Gods. It will be my main DNS server
            	newServer("${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv4.addresses 0).address}:5353", pool="zeus")
            	newServer("${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0).address}:5353", pool="zeus")

             	-- Poseidon will run my DN42. It will run the DNS for DN42
            	newServer("${(builtins.elemAt inputs.self.nixosConfigurations.poseidon.config.networking.interfaces.ens192.ipv4.addresses 0).address}:53", pool="poseidon", checkName="nlgld.dn42", checkType="SOA", mustResolve=true)
            	newServer("${(builtins.elemAt inputs.self.nixosConfigurations.poseidon.config.networking.interfaces.ens192.ipv6.addresses 0).address}:53", pool="poseidon", checkName="nlgld.dn42", checkType="SOA", mustResolve=true)

              -- Upstream DNS server, it also serves some unique zones I might want to read
              newServer("10.0.111.2:53", pool="upstream")
              -- newServer("[2a07:54c1:4932:111::2]:53", pool="upstream") -- (Server does not (yet) support IPv6)

              -- Fallback for the internet: {1-4}.dns.nothingtohide.nl
              local hosts = {
                {ip = "192.42.116.9",   name = "1.dns.nothingtohide.nl"},
                {ip = "192.42.116.39",  name = "2.dns.nothingtohide.nl"},
                {ip = "192.42.116.89",  name = "3.dns.nothingtohide.nl"},
                {ip = "192.42.116.139", name = "4.dns.nothingtohide.nl"},
                {ip = "[2001:67c:e60:c0c::53:1]", name = "1.dns.nothingtohide.nl"},
                {ip = "[2001:67c:e60:c0c::53:2]", name = "2.dns.nothingtohide.nl"},
                {ip = "[2001:67c:e60:c0c::53:3]", name = "3.dns.nothingtohide.nl"},
                {ip = "[2001:67c:e60:c0c::53:4]", name = "4.dns.nothingtohide.nl"},
              }
              for _, h in ipairs(hosts) do
                -- DNS-over-HTTPS, TCP/443
                newServer({
                  address              = h.ip .. ":443",
                  name                 = "doh-" .. h.name,
                  tls                  = "openssl",
                  dohPath              = "/dns-query",
                  subjectName          = h.name,
                  validateCertificates = true,
                  weight               = 1,
                  pool                 = "internet",
                })
                -- DNS-over-TLS, TCP/853
                newServer({
                  address              = h.ip .. ":853",
                  name                 = "dot-" .. h.name,
                  tls                  = "openssl",
                  subjectName          = h.name,
                  validateCertificates = true,
                  weight               = 1,
                  pool                 = "internet",
                })
              end

              addAction(QNameSuffixRule({"16.dapperepoging.nl.", "116.0.10.in-addr.arpa.", "6.1.1.2.3.9.4.1.c.4.5.7.0.a.2.ip6.arpa."}), PoolAction("zeus"))
              addAction(QNameSuffixRule({"dapperepoging.nl.","111.0.10.in-addr.arpa."}), PoolAction("upstream"))
              addAction(QNameSuffixRule({"dn42.", "20.172.in-addr.arpa.", "21.172.in-addr.arpa.", "22.172.in-addr.arpa.", "23.172.in-addr.arpa.", "d.f.ip6.arpa."}), PoolAction("poseidon"))

              -- Catch AS112 zones before they hit the internet
              addAction(QNameSuffixRule({"localhost", "127.in-addr.arpa", "0.in-addr.arpa", "255.in-addr.arpa", "254.169.in-addr.arpa", "2.0.192.in-addr.arpa", "100.51.198.in-addr.arpa", "113.0.203.in-addr.arpa", "10.in-addr.arpa", "16.172.in-addr.arpa", "17.172.in-addr.arpa", "18.172.in-addr.arpa", "19.172.in-addr.arpa", "20.172.in-addr.arpa", "21.172.in-addr.arpa", "22.172.in-addr.arpa", "23.172.in-addr.arpa", "24.172.in-addr.arpa", "25.172.in-addr.arpa", "26.172.in-addr.arpa", "27.172.in-addr.arpa", "28.172.in-addr.arpa", "29.172.in-addr.arpa", "30.172.in-addr.arpa", "31.172.in-addr.arpa", "168.192.in-addr.arpa", "64.100.in-addr.arpa", "65.100.in-addr.arpa", "66.100.in-addr.arpa", "67.100.in-addr.arpa", "68.100.in-addr.arpa", "69.100.in-addr.arpa", "70.100.in-addr.arpa", "71.100.in-addr.arpa", "72.100.in-addr.arpa", "73.100.in-addr.arpa", "74.100.in-addr.arpa", "75.100.in-addr.arpa", "76.100.in-addr.arpa", "77.100.in-addr.arpa", "78.100.in-addr.arpa", "79.100.in-addr.arpa", "80.100.in-addr.arpa", "81.100.in-addr.arpa", "82.100.in-addr.arpa", "83.100.in-addr.arpa", "84.100.in-addr.arpa", "85.100.in-addr.arpa", "86.100.in-addr.arpa", "87.100.in-addr.arpa", "88.100.in-addr.arpa", "89.100.in-addr.arpa", "90.100.in-addr.arpa", "91.100.in-addr.arpa", "92.100.in-addr.arpa", "93.100.in-addr.arpa", "94.100.in-addr.arpa", "95.100.in-addr.arpa", "96.100.in-addr.arpa", "97.100.in-addr.arpa", "98.100.in-addr.arpa", "99.100.in-addr.arpa", "100.100.in-addr.arpa", "101.100.in-addr.arpa", "102.100.in-addr.arpa", "103.100.in-addr.arpa", "104.100.in-addr.arpa", "105.100.in-addr.arpa", "106.100.in-addr.arpa", "107.100.in-addr.arpa", "108.100.in-addr.arpa", "109.100.in-addr.arpa", "110.100.in-addr.arpa", "111.100.in-addr.arpa", "112.100.in-addr.arpa", "113.100.in-addr.arpa", "114.100.in-addr.arpa", "115.100.in-addr.arpa", "116.100.in-addr.arpa", "117.100.in-addr.arpa", "118.100.in-addr.arpa", "119.100.in-addr.arpa", "120.100.in-addr.arpa", "121.100.in-addr.arpa", "122.100.in-addr.arpa", "123.100.in-addr.arpa", "124.100.in-addr.arpa", "125.100.in-addr.arpa", "126.100.in-addr.arpa", "127.100.in-addr.arpa", "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa", "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa", "d.f.ip6.arpa", "8.e.f.ip6.arpa", "9.e.f.ip6.arpa", "a.e.f.ip6.arpa", "b.e.f.ip6.arpa", "8.b.d.0.1.0.0.2.ip6.arpa"}), PoolAction("zeus"))

              -- Redirect everything to the nothingtohide.nl DNS servers
              addAction(AllRule(), PoolAction("internet"))
        		'';
  };
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}

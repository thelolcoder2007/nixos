{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  services.zabbixAgent = {
    enable = true;
    server =
      let
        getZabbixAddresses =
          host:
          let
            isEnabled = host.config.services.zabbixServer.enable or host.config.services.zabbixProxy.enable;

            allInterfaceAddresses = builtins.concatMap (
              iface:
              let
                v4 =
                  if (builtins.hasAttr "ipv4" iface && builtins.hasAttr "addresses" iface.ipv4) then
                    iface.ipv4.addresses
                  else
                    [ ];
                v6 =
                  if (builtins.hasAttr "ipv6" iface && builtins.hasAttr "addresses" iface.ipv6) then
                    iface.ipv6.addresses
                  else
                    [ ];
              in
              (map (addr: addr.address) v4) ++ (map (addr: addr.address) v6)
            ) (builtins.attrValues host.config.networking.interfaces);
          in
          if isEnabled then allInterfaceAddresses else [ ];

        allActiveZabbixIPs = builtins.concatLists (
          map getZabbixAddresses (builtins.attrValues inputs.self.nixosConfigurations)
        );
      in
      (builtins.concatStringsSep "," allActiveZabbixIPs)
      + ",127.0.0.1,::1,10.0.111.8,2a07:54c1:4932:111::8";
    settings = {
      Hostname = config.networking.hostName;
      UserParameter =
        let
          nix-pkgs-list = pkgs.writeShellScript "linecount-nixpkgs.sh" ''
            cat /etc/current-system-packages | wc -l
          '';
        in
        [
          "ss.tcp.listening.netstat,'${lib.getExe' pkgs.net-tools "netstat"} --tcp --listening --numeric-ports'"
          "x.system.sw.packages.get,${nix-pkgs-list}"
        ];
    };
    package = pkgs.zabbix74.agent2;
  };
  # systemd.services.zabbix-agent.serviceConfig.ReadOnlyPaths = [ "/etc/nixos/nixos" ];
  environment.etc."current-system-packages".text =
    let
      packages = map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
    in
    builtins.concatStringsSep "\n" sortedUnique;
}

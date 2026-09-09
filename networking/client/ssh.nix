{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.openssh = {
    enable = true;
    listenAddresses = [
      {
        addr = (builtins.elemAt config.networking.interfaces.ens192.ipv4.addresses 0).address;
      }
      {
        addr = (builtins.elemAt config.networking.interfaces.ens192.ipv6.addresses 0).address;
      }
    ];
  };
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    bantime-increment.enable = true;
    maxretry = 10;
  };
  services.zabbixAgent.settings.UserParameter = [
    "fail2ban.status[*],${lib.getExe' pkgs.fail2ban "fail2ban-client"} status '$1' | grep 'Currently banned:' | grep -E -o '[0-9]+' "
    "fail2ban.discovery,${lib.getExe' pkgs.fail2ban "fail2ban-client"} | grep 'Jail list:' | sed -e 's/^.*:\W\+//' -e 's/\(\(\w\|-\)\+\)/{'{#JAIL}':'\1'}/g' -e 's/.*/{'data':[\0]}/'''"
    "ss.tcp.listening,${lib.getExe' pkgs.net-tools "netstat"} --tcp --listening --numeric-ports"
  ];
}

{ config, ... }:

{
  services.tftpd = {
    enable = true;
    path = "/srv/tftp";
  };
  systemd.tmpfiles.rules = [ "d ${config.services.tftpd.path} 0755 root root -" ]; # Actually make the directory we're pointing at
}

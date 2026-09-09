{
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    updater.interval = "hourly";

    scanner.enable = true;
    scanner.interval = "*-*-* 04:00:00"; # Every day at 04:00 AM
  };
}

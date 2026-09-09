{
  TTL = 604800; # 1 week
  SOA = {
    nameServer = "localhost.";
    adminEmail = "root@localhost";
    serial = 1;
    refresh = 604800; # 1 week
    retry = 2592000; # 30 days
    expire = 604800; # 1 week
    minimum = 604800; # 1 week
  };
  ns = [ "localhost." ];
  A = "127.0.0.1";
  AAAA = "::1";
}

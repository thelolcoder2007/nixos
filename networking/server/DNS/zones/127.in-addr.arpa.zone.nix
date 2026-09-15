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
  NS = [ "localhost." ];
  subdomains."1.0.0".PTR = [ "localhost." ];
}

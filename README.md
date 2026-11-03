# nixos

## TODO

- [x] Make nginx work modularly without weird `(import ./bullshit.nix)` shennanigans
- [x] Implement database/postgres.nix
- [x] Implement networking/server/HTTP/defaults.nix
- [x] Implement Poseidon
- [x] Find a better place for networking/server/BGP/DN42-cert.nix
- [x] Make sure the cert gets checked every couple days
- [x] Add ACME server
- [ ] Make sure nixos hosts can receive certs from ACME server (`x.nginx.virtualHosts.<name>.localAcmeHost`)
- [ ] Add centralized logging facility to Hera
- [ ] Make all logs point to Hera instead of local files
- [ ] Make up a name for games server
- [ ] Add games
- [ ] Set up impermanence

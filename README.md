# nixos

## TODO

- [x] Make nginx work modularly without weird `(import ./bullshit.nix)` shennanigans
- [x] Implement database/postgres.nix
- [x] Implement networking/server/HTTP/defaults.nix
- [x] Implement Poseidon
- [x] Find a better place for networking/server/BGP/DN42-cert.nix
- [x] Make sure the cert gets checked every couple days
- [ ] Add ACME server
- [ ] Make sure nixos hosts can receive certs from ACME server (`x.nginx.virtualHosts.<name>.localAcmeHost`)
- [ ] Make up a name for games server
- [ ] Add games
- [ ] Add hydra buildserver named Athena
- [ ] Add mediaserver named Apollo

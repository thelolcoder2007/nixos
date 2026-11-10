.SILENT: update push pull
.PHONY: update push pull build

update:
ifdef XENOI
	nh os switch -u --commit-lock-file --target-host "thomas@10.0.116.125" -H "xenoi"
endif
	nh os switch --target-host "thomas@10.0.116.9" -H "poseidon"
	nh os switch --target-host "thomas@10.0.116.5" -H "zeus"
	${MAKE} push

pull push:
	git push
ifdef XENOI
	ssh thomas@10.0.116.125 "git -C /etc/nixos/nixos pull"
endif
	ssh thomas@10.0.116.9 "git -C /etc/nixos/nixos pull"
	ssh thomas@10.0.116.5 "git -C /etc/nixos/nixos pull"

build:
	nix flake update --commit-lock-file
	nh os build -H hera -d never
	# nh os build -H hermes -d never # Hermes is temporarily borken
	nh os build -H pankration -d never
	nh os build -H poseidon -d never
	nh os build -H xenoi -d never
	nh os build -H zeus -d never
	rm result

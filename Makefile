.SILENT: update push pull
.PHONY: update push pull build iso

update:
ifdef XENOI
	nh os switch -u --commit-lock-file --target-host xenoi -H "xenoi"
	nh os switch --target-host poseidon -H "poseidon"
else
	nh os switch -u --commit-lock-file --target-host poseidon -H poseidon
endif
	nh os switch --target-host zeus -H "zeus"
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
	nh os build -H hermes -d never
	nh os build -H pankration -d never
	nh os build -H poseidon -d never
	nh os build -H xenoi -d never
	nh os build -H zeus -d never
	rm result

iso:
	nix flake update --commit-lock-file
	nh os build-image --image-variant iso -H hera -d never
	nh os build-image --image-variant iso -H hermes -d never
	nh os build-image --image-variant iso -H pankration -d never
	nh os build-image --image-variant iso -H poseidon -d never
	nh os build-image --image-variant iso -H xenoi -d never
	nh os build-image --image-variant iso -H zeus -d never
	rm result

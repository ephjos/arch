# arch

My arch linux installation scripts and configs. Pulls in my [dotfiles](https://github.com/ephjos/dotfiles).

## Getting started

1. Boot into an arch iso
2. `curl -L0 ephjos.com/i.sh | sh` and run through the installer
3. Select "chroot into the installation" at the end of archinstall
4. `curl -L0 ephjos.com/p.sh | sh`
5. Reboot

## Development

1. Download an Arch Linux ISO from https://archlinux.org/download/
2. Place it in this directory
3. Rename it to `archlinux.iso`
4. `make boot` to boot into the installer
5. Install and shutdown
6. `make boot` to boot into the installed OS
7. `make dev` to start webserver and enable fetching local files at `http://10.0.2.2:8000/` inside of the VM


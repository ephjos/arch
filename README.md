# arch

My arch linux installation scripts and configs. Pulls in my [dotfiles](https://github.com/ephjos/dotfiles).

## Getting started

1. Boot into an arch iso
1. Connect internet
1. `curl -L0 ephjos.com/i.sh | sh` and run through the installer
1. Select "chroot into the installation" at the end of archinstall
1. `curl -L0 ephjos.com/p.sh | sh`
1. Reboot

## Development

1. Download an Arch Linux ISO from https://archlinux.org/download/
1. Place it in this directory
1. Rename it to `archlinux.iso`
1. `make boot` to boot into the installer
1. Install and shutdown
1. `make boot` to boot into the installed OS
1. `make dev` to start webserver and enable fetching local files at `http://10.0.2.2:8000/` inside of the VM
    - Run the scripts with the `--dev` flag to have them do this internally

## Notes

### Wallpapers

I store wallpapers in a personal drive. 

1. Download the correct wallpaper
1. Run `e_setbg` on the file

### Fonts

I use TX-02 by [U.S. Graphics Company](https://usgraphics.com/) with a fallback to NotoSansMono. I store my build of this font in a personal drive.

1. Download the fonts
1. Place the `.otf` files in `~/.local/share/fonts/` 
1. Run `fc-cache` (maybe pass `--force` if needed).
1. Run `fc-list` and confirm the TX-02 fonts are present. 
1. Log out
1. Log back in

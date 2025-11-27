#!/bin/bash
#

# Constants
dotfilesrepo="https://github.com/ephjos/dotfiles.git"
#programsfile="http://10.0.2.2:8000/programs"
programsfile="https://raw.githubusercontent.com/ephjos/arch/refs/heads/main/programs"

# Set "installpkg" to use the right package manager
installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1; }

# Prompting tools
infoPrompt() { read -p "$1 :" < /dev/tty; }

prompt() {
    read -p "$1
  > " $2 < /dev/tty;
}

promptSilent() {
    read -sp "$1
  > " $2 < /dev/tty;
  echo;
}

promptRequired() {
    prompt "$1" "$2";
    while [ "${!2}" == "" ]; do
        prompt "No value provided, $1" "$2";
    done;
}

error() { echo "$1"; exit; }

# Core functions

getUsername() {
    promptRequired "Please provide a username" username;
    while ! echo "$username" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
        promptRequired 'Username must start with a letter or underscore,
and can only contain letters, numbers, -, and _' username;
    done;
}

updateGroups() {
    echo "Updating groups for $username";
    useradd -m -g wheel -s /bin/bash "$username" >/dev/null 2>&1 || \
        usermod -a -G wheel "$username" && \
        mkdir -p /home/"$username" && \
        chown "$username":wheel /home/"$username";
    repodir="/home/$username/.local/src";
    mkdir -p "$repodir";
    chown -R "$username":wheel "$(dirname "$repodir")";
}

refreshKeys() {
    echo "Refreshing arch keyring";
    pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1;
}

newperms() {
    sed -i "/#MARKER/d" /etc/sudoers;
    echo "$* #MARKER" >> /etc/sudoers;
}

manualinstall() {
    [ -f "/usr/bin/$1" ] || (
        echo "Installing \"$1\", an AUR helper..."
        cd /tmp || exit
        rm -rf /tmp/"$1"*
        curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
        sudo -u "$username" tar -xvf "$1".tar.gz &&
        cd "$1" &&
        sudo -u "$username" makepkg --noconfirm -si
        cd /tmp || return);
}

archPreInstall() {
    [ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers

    # Allow user to run sudo without password. Since AUR programs must be
    # installed in a fakeroot environment, this is required for all
    # builds with AUR.
    newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

    # Make pacman and yay colorful and adds eye candy on the
    # progress bar because why not.
    grep "^Color" /etc/pacman.conf >/dev/null || \
        sed -i "s/^#Color$/Color/" /etc/pacman.conf
    grep "ILoveCandy" /etc/pacman.conf >/dev/null || \
        sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

    # Use all cores for compilation.
    sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

    manualinstall yay || error "Failed to install AUR helper."
}

installPrograms() {
    echo "Installing necessary programs"
    curl -Ls "$programsfile" | sed '/^#/d' > /tmp/programs
    sudo -u "$username" xargs yay -S --noconfirm < /tmp/programs
}

cloneDotfiles() {
    echo "Installing dotfiles"
    putgitrepo "$dotfilesrepo" "/home/$username" 
    rm -rf \
        "/home/$username/README.md" \
        "/home/$username/LICENSE" \
        "/home/$username/FUNDING.yml" \
        "/home/$username/.git"
}

# Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts
putgitrepo() {
    [ -z "$3" ] && branch="master"
    dir=$(mktemp -d)
    [ ! -d "$2" ] && mkdir -p "$2"
    chown -R "$username":wheel "$dir" "$2"
    sudo -u "$username" \git clone --recursive -b "$branch" --depth 1 "$1" "$dir" \
        >/dev/null 2>&1
    sudo -u "$username" cp -rfT "$dir" "$2"
}

finalize() {
    echo "All done! Assuming everything went well, you should be able to\
log into $username and be up and running!"
}

#
# Program beings here
#

installpkg curl || error "Are you sure you're running this as the root \
user and have an internet connection?";

getUsername || error "Could not get username";
updateGroups || error "Error adding username and/or password.";
refreshKeys || error "Error automatically refreshing Arch keyring. \
Consider doing so manually.";

archPreInstall || error "Unable to execute arch pre install";

installPrograms;

cloneDotfiles || error "Error installing dotfiles"

dbus-uuidgen > /var/lib/dbus/machine-id

newperms "%wheel ALL=(ALL) ALL #MARKER
%wheel ALL=(ALL) NOPASSWD: \
/usr/bin/shutdown,\
/usr/bin/reboot,\
/usr/bin/systemctl,\
/usr/bin/mount,\
/usr/bin/umount,\
/usr/bin/pacman,\
/usr/bin/yay"

finalize


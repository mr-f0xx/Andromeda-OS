#!/bin/bash -e
export DEBIAN_FRONTEND=noninteractive
apt-get update
# Include the runtime extras the regular installer installs in addition to the deb.
PT35_USER=pi apt-get install -y /root/pt35-desktop_arm64.deb \
  network-manager bluez pipewire-alsa xwayland wl-clipboard \
  papirus-icon-theme i2c-tools evtest python3-serial htop \
  qt5-gtk-platformtheme qt6-gtk-platformtheme fastfetch bibata-cursor-theme ncdu \
  chromium locales
rm /root/pt35-desktop_arm64.deb
sed -i 's/^# *fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
locale-gen fr_FR.UTF-8
# postinst deliberately skips systemctl in a chroot. Do not switch to the
# graphical target here: pi-gen's user-rename setup must see a Lite/CLI image.
systemctl enable NetworkManager.service seatd.service keyd.service greetd.service pt35-image-setup.service
systemctl disable ssh.service

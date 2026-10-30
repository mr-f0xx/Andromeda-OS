#!/bin/bash -e
# The workflow supplies the package built from this checkout, not a release.
install -m 644 files/pt35-desktop_arm64.deb "${ROOTFS_DIR}/root/pt35-desktop_arm64.deb"
install -Dm755 files/pt35-image-setup "${ROOTFS_DIR}/usr/lib/pt35/pt35-image-setup"
install -Dm644 files/pt35-image-setup.service "${ROOTFS_DIR}/etc/systemd/system/pt35-image-setup.service"
install -Dm644 files/greetd-image.conf "${ROOTFS_DIR}/etc/systemd/system/greetd.service.d/image-setup.conf"
install -Dm644 files/image-build-info "${ROOTFS_DIR}/usr/share/pt35-desktop/image-build-info"

#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-YOUSEF-Browser-OS.img}"
SIZE_MB="${SIZE_MB:-4096}"
ROOTFS="${PWD}/rootfs"
MNT="${PWD}/mnt-root"
WORK="${PWD}/work"

rm -rf "$ROOTFS" "$MNT" "$WORK" "$IMAGE"
mkdir -p "$ROOTFS" "$MNT" "$WORK"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y debootstrap grub-pc-bin grub-common xorriso parted e2fsprogs dosfstools

debootstrap --arch=amd64 --variant=minbase bookworm "$ROOTFS" http://deb.debian.org/debian

cat > "$ROOTFS/etc/apt/sources.list" <<'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
EOF

cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"

mount --bind /dev "$ROOTFS/dev"
mount --bind /dev/pts "$ROOTFS/dev/pts"
mount -t proc proc "$ROOTFS/proc"
mount -t sysfs sysfs "$ROOTFS/sys"
mount -t tmpfs tmpfs "$ROOTFS/run"

cat > "$ROOTFS/tmp/setup.sh" <<'EOF'
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y linux-image-amd64 systemd-sysv sudo dbus-x11 xorg openbox xterm firefox-esr network-manager network-manager-gnome fonts-dejavu fonts-noto-core ca-certificates curl

useradd -m -s /bin/bash yousef || true
echo 'yousef:yousef' | chpasswd
usermod -aG sudo,netdev yousef
systemctl enable NetworkManager

mkdir -p /home/yousef/.config/openbox
cat > /home/yousef/.config/openbox/autostart <<'AUTO'
xsetroot -solid '#0b1220'
(sleep 2; firefox-esr --kiosk --private-window "https://www.google.com") &
AUTO

cat > /home/yousef/.xinitrc <<'XINIT'
exec openbox-session
XINIT

chown -R yousef:yousef /home/yousef
chmod +x /home/yousef/.xinitrc

cat > /etc/systemd/system/browser-session.service <<'UNIT'
[Unit]
After=network-online.target
Wants=network-online.target
Conflicts=getty@tty1.service

[Service]
User=yousef
Environment=HOME=/home/yousef
Environment=DISPLAY=:0
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
ExecStart=/usr/bin/startx /home/yousef/.xinitrc -- :0 vt1 -nolisten tcp
Restart=always
RestartSec=2

[Install]
WantedBy=graphical.target
UNIT

systemctl enable browser-session.service

cat > /etc/issue <<'ISSUE'
YOUSEF Browser OS
Browser-only edition
Login: yousef / yousef
ISSUE

echo 'YOUSEF Browser OS' > /etc/hostname
rm -f /etc/machine-id
systemd-machine-id-setup
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

chmod +x "$ROOTFS/tmp/setup.sh"
chroot "$ROOTFS" /tmp/setup.sh
rm -f "$ROOTFS/tmp/setup.sh"

umount -lf "$ROOTFS/run" "$ROOTFS/sys" "$ROOTFS/proc" "$ROOTFS/dev/pts" "$ROOTFS/dev"

truncate -s "${SIZE_MB}M" "$IMAGE"
parted -s "$IMAGE" mklabel msdos
parted -s "$IMAGE" mkpart primary ext4 1MiB 100%
parted -s "$IMAGE" set 1 boot on

LOOP=$(losetup --find --show --partscan "$IMAGE")
mkfs.ext4 -F "${LOOP}p1"
mount "${LOOP}p1" "$MNT"
cp -a "$ROOTFS"/. "$MNT"/
mkdir -p "$MNT/boot"

mount --bind /dev "$MNT/dev"
mount --bind /dev/pts "$MNT/dev/pts"
mount -t proc proc "$MNT/proc"
mount -t sysfs sysfs "$MNT/sys"
mount -t tmpfs tmpfs "$MNT/run"

chroot "$MNT" grub-install --target=i386-pc --boot-directory=/boot "$LOOP"
chroot "$MNT" update-grub

umount -lf "$MNT/run" "$MNT/sys" "$MNT/proc" "$MNT/dev/pts" "$MNT/dev"
umount "$MNT"
losetup -d "$LOOP"
e2fsck -fy "$IMAGE" || true
resize2fs -M "$IMAGE" || true

echo "Built $IMAGE"

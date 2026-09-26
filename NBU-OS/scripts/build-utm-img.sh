#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

command -v sfdisk >/dev/null
command -v losetup >/dev/null
command -v mkfs.ext2 >/dev/null
command -v mount >/dev/null
command -v grub-install >/dev/null

IMG="$(pwd)/dist/NBU-OS-UTM.img"
MNT="$(mktemp -d)"
LOOP=""

cleanup() {
  set +e
  if mountpoint -q "$MNT"; then sudo umount "$MNT"; fi
  if [[ -n "$LOOP" ]]; then sudo losetup -d "$LOOP" 2>/dev/null || true; fi
  rm -rf "$MNT"
}
trap cleanup EXIT

mkdir -p dist
rm -f "$IMG"
truncate -s 128M "$IMG"

sudo sfdisk "$IMG" <<'EOF'
label: dos
unit: sectors

start=2048, type=83, bootable
EOF

LOOP="$(sudo losetup --find --show --partscan "$IMG")"
sleep 1

sudo mkfs.ext2 -F -L NBU_OS "${LOOP}p1"
sudo mount "${LOOP}p1" "$MNT"

sudo mkdir -p "$MNT/boot/grub"
sudo cp build/nbu-kernel.elf "$MNT/boot/nbu-kernel.elf"
sudo cp VERSION "$MNT/boot/NBU-OS.version"

sudo sh -c 'cat > "'"$MNT"'/boot/grub/grub.cfg" <<EOF
set timeout=0
set default=0
set gfxmode=1024x768x32
set gfxpayload=1024x768x32
insmod all_video
menuentry "NBU-OS GUI" {
  multiboot2 /boot/nbu-kernel.elf
  boot
}
EOF'

sudo grub-install --target=i386-pc --boot-directory="$MNT/boot" --no-floppy --recheck "$IMG"

sync
echo "Created UTM SE BIOS/MBR image: $IMG"
echo "IMG size: $(du -h "$IMG" | cut -f1)"

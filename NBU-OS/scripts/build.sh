#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
make iso
./scripts/check_iso.sh dist/NBU-OS.iso
command -v sgdisk >/dev/null
command -v losetup >/dev/null
command -v mkfs.vfat >/dev/null
command -v mount >/dev/null
command -v grub-install >/dev/null
IMG="$(pwd)/dist/NBU-OS.img"
MNT="$(mktemp -d)"
LOOP=""
cleanup() {
  set +e
  if mountpoint -q "$MNT"; then sudo umount "$MNT"; fi
  if [[ -n "$LOOP" ]]; then sudo losetup -d "$LOOP" 2>/dev/null || true; fi
  rm -rf "$MNT"
}
trap cleanup EXIT
rm -f "$IMG"
truncate -s 128M "$IMG"
sudo sgdisk --zap-all "$IMG"
sudo sgdisk --new=1:2048:67583 --typecode=1:ef00 --change-name=1:"NBU EFI" --new=2:67584:69631 --typecode=2:ef02 --change-name=2:"BIOS Boot" --new=3:69632:0 --typecode=3:0700 --change-name=3:"NBU Data" "$IMG"
LOOP="$(sudo losetup --find --show --partscan "$IMG")"
sleep 1
sudo mkfs.vfat -F 32 -n NBU_EFI "${LOOP}p1"
sudo mount "${LOOP}p1" "$MNT"
sudo mkdir -p "$MNT/boot/grub"
sudo cp build/nbu-kernel.elf "$MNT/boot/nbu-kernel.elf"
sudo cp VERSION "$MNT/boot/NBU-OS.version"
sudo sh -c 'cat > "'"$MNT"'/boot/grub/grub.cfg" <<EOF
set timeout=0
set default=0
set gfxmode=1024x768x32
set gfxpayload=keep
insmod all_video
menuentry "NBU-OS GUI" {
  multiboot2 /boot/nbu-kernel.elf
  boot
}
EOF'
sudo grub-install --target=x86_64-efi --efi-directory="$MNT" --boot-directory="$MNT/boot" --removable --no-nvram --recheck "$IMG"
sudo grub-install --target=i386-pc --boot-directory="$MNT/boot" --no-floppy --recheck "$IMG"
sync
echo "Created: $(pwd)/dist/NBU-OS.iso"
echo "Created: $(pwd)/dist/NBU-OS.img"
echo "IMG size: $(du -h "$IMG" | cut -f1)"

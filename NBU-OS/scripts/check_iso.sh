#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."

mode=boot
image_path="$(pwd)/build/NBU-OS.iso"
if [[ ${1:-} == --structure-only ]]; then
    mode=structure
    shift
fi
if [[ $# -gt 0 ]]; then
    image_path=$(realpath "$1")
fi
img_path="${image_path%.iso}.img"

fail() {
    printf 'Boot image check failed: %s\n' "$1" >&2
    exit 1
}

[[ -f "$image_path" ]] || fail "ISO not found: $image_path (run ./build.sh first)"
for tool in file xorriso grub-file; do
    command -v "$tool" >/dev/null || fail "required tool missing: $tool"
done

file_description=$(file -b "$image_path")
[[ $file_description == *"ISO 9660"* ]] || fail "not an ISO-9660 image: $file_description"
iso_listing=$(xorriso -indev "$image_path" -find / -type f -exec echo 2>&1) || fail "xorriso could not read the ISO"
grep -Fq '/boot/nbu-kernel.elf' <<< "$iso_listing" || fail "kernel missing from /boot/nbu-kernel.elf"
grep -Fq '/boot/grub/grub.cfg' <<< "$iso_listing" || fail "GRUB config missing from /boot/grub/grub.cfg"
grep -Fq '/boot/NBU-OS.version' <<< "$iso_listing" || fail "version metadata missing from /boot/NBU-OS.version"

kernel_file=$(mktemp)
trap 'rm -f "$kernel_file"' EXIT
xorriso -osirrox on -indev "$image_path" -extract /boot/nbu-kernel.elf "$kernel_file" >/dev/null 2>&1 || fail "could not extract kernel from ISO"
kernel_description=$(file -b "$kernel_file")
[[ $kernel_description == *"ELF 64-bit"* && $kernel_description == *"x86-64"* ]] || fail "kernel is not an x86_64 ELF: $kernel_description"
grub-file --is-x86-multiboot2 "$kernel_file" || fail "kernel has no valid Multiboot2 header"

el_torito_report=$(xorriso -indev "$image_path" -report_el_torito plain 2>&1) || fail "could not inspect El Torito boot records"
grep -Fq 'BIOS' <<< "$el_torito_report" || fail "no BIOS El Torito boot entry found"
[[ -f "$img_path" ]] || fail "raw IMG not found: $img_path"
command -v sgdisk >/dev/null || fail "sgdisk missing; required to inspect GPT IMG"
gpt_report=$(sgdisk --print "$img_path" 2>&1) || fail "IMG is not a valid GPT disk image"
grep -Fq 'NBU EFI' <<< "$gpt_report" || fail "EFI System Partition missing from IMG"
grep -Fq 'BIOS Boot' <<< "$gpt_report" || fail "BIOS Boot partition missing from IMG"
printf 'ISO structure OK: %s\n' "$image_path"
printf 'GPT IMG structure OK: %s\n' "$img_path"

if [[ $mode == boot ]]; then
    command -v qemu-system-x86_64 >/dev/null || fail "qemu-system-x86_64 missing; install QEMU or use --structure-only"
    command -v timeout >/dev/null || fail "timeout command missing"
    boot_check() {
        local medium=$1
        local image=$2
        local -a source_args
        if [[ $medium == cdrom ]]; then
            source_args=(-cdrom "$image" -boot d)
        else
            source_args=(-drive "file=$image,format=raw,if=ide" -boot c)
        fi
        local qemu_output qemu_status
        set +e
        qemu_output=$(timeout 10s qemu-system-x86_64 \
            -machine q35,accel=tcg -m 2048 "${source_args[@]}" \
            -display none -serial stdio -monitor none -no-reboot -no-shutdown 2>&1)
        qemu_status=$?
        set -e
        if [[ $qemu_output != *"NBU-OS: kernel entry reached"* ]]; then
            printf '%s\n' "$qemu_output" >&2
            fail "QEMU did not reach the kernel from $medium image (exit $qemu_status)"
        fi
        printf 'QEMU boot OK from %s on Q35: kernel entry reached.\n' "$medium"
    }
    boot_check cdrom "$image_path"
    boot_check disk "$img_path"
fi

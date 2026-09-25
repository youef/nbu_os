#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
[[ -f build/NBU-OS.iso ]] || ./scripts/build.sh
exec qemu-system-x86_64 -machine q35,accel=tcg -m 2048 \
	-cdrom build/NBU-OS.iso -boot d -serial stdio -display gtk

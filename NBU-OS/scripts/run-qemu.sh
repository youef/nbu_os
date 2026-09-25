#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
[[ -f dist/NBU-OS.iso ]] || ./scripts/build.sh
exec qemu-system-x86_64 -cdrom dist/NBU-OS.iso -m 512M -serial stdio -display gtk

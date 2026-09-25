#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
command -v grub-mkrescue >/dev/null || { echo "grub-mkrescue is required" >&2; exit 2; }
mkdir -p dist
make iso
echo "Created dist/NBU-OS.iso"

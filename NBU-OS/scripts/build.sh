#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
make iso
./scripts/check_iso.sh build/NBU-OS.iso
echo "Created $(pwd)/build/NBU-OS.iso and $(pwd)/build/NBU-OS.img"

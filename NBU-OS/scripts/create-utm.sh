#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")/.."

# Build the dedicated UTM SE raw disk if it does not exist.
if [[ ! -f dist/NBU-OS-UTM.img ]]; then
  ./scripts/build.sh
  ./scripts/build-utm-img.sh
fi

test -f dist/NBU-OS-UTM.img

rm -rf dist/NBU-OS.utm
mkdir -p dist/NBU-OS.utm

# UTM/QEMU configuration:
# - x86_64 guest
# - Standard PC / i440FX-compatible machine
# - Legacy BIOS (UEFI disabled)
# - IDE raw disk
# - no ISO/CD drive, so the disk is the first and only boot device
cat > dist/NBU-OS.utm/config.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Backend</key>
    <string>QEMU</string>

    <key>ConfigurationVersion</key>
    <integer>4</integer>

    <key>Information</key>
    <dict>
        <key>Name</key>
        <string>NBU-OS</string>
        <key>Notes</key>
        <string>NBU-OS v0.5.0-alpha4 — UTM SE ready image</string>
    </dict>

    <key>System</key>
    <dict>
        <key>Architecture</key>
        <string>x86_64</string>
        <key>CPU</key>
        <string>default</string>
        <key>CPUCount</key>
        <integer>2</integer>
        <key>MemorySize</key>
        <integer>1024</integer>
        <key>Target</key>
        <string>pc-i440fx-7.2</string>
    </dict>

    <key>QEMU</key>
    <dict>
        <key>Hypervisor</key>
        <false/>
        <key>UEFIBoot</key>
        <false/>
    </dict>

    <key>Display</key>
    <array>
        <dict>
            <key>Hardware</key>
            <string>virtio-vga</string>
            <key>DynamicResolution</key>
            <false/>
            <key>NativeResolution</key>
            <false/>
        </dict>
    </array>

    <key>Input</key>
    <dict>
        <key>UsbSharing</key>
        <false/>
    </dict>

    <key>Drive</key>
    <array>
        <dict>
            <key>Identifier</key>
            <string>NBU-OS-UTM-DISK</string>
            <key>ImagePath</key>
            <string>NBU-OS-UTM.img</string>
            <key>ImageType</key>
            <string>Disk</string>
            <key>Interface</key>
            <string>IDE</string>
            <key>InterfaceVersion</key>
            <integer>1</integer>
            <key>Removable</key>
            <false/>
            <key>ReadOnly</key>
            <false/>
        </dict>
    </array>

    <key>Network</key>
    <array/>
    <key>Serial</key>
    <array/>
</dict>
</plist>
PLIST

cp dist/NBU-OS-UTM.img dist/NBU-OS.utm/NBU-OS-UTM.img

# Keep a small manifest inside the package for easy verification.
sha256sum dist/NBU-OS.utm/NBU-OS-UTM.img > dist/NBU-OS.utm/SHA256SUMS

# Validate the plist structure on Linux CI when plutil is unavailable.
python3 - <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path
p = Path("dist/NBU-OS.utm/config.plist")
ET.parse(p)
print(f"Validated {p}")
PY

echo "Created ready-to-import dist/NBU-OS.utm"

#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
[[ -f build/NBU-OS.iso ]] || ./scripts/build.sh
mkdir -p build/NBU-OS.utm
cat > build/NBU-OS.utm/config.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Backend</key><string>QEMU</string>
<key>ConfigurationVersion</key><integer>4</integer>
<key>Information</key><dict><key>Name</key><string>NBU-OS</string><key>Notes</key><string>يوسف الحازمي | جامعة الحدود الشمالية - الإدارة العامة للتحول الرقمي</string></dict>
<key>System</key><dict><key>Architecture</key><string>x86_64</string><key>CPU</key><string>host</string><key>Memory</key><integer>2048</integer><key>CPUCount</key><integer>2</integer></dict>
<key>Display</key><dict><key>Type</key><string>virtio-gpu-pci</string></dict>
<key>Drives</key><array><dict><key>ImageType</key><string>CD</string><key>ImagePath</key><string>NBU-OS.iso</string><key>Interface</key><string>IDE</string><key>Removable</key><true/></dict></array>
<key>Serial</key><dict><key>Mode</key><string>None</string></dict>
</dict></plist>
PLIST
cp build/NBU-OS.iso build/NBU-OS.utm/NBU-OS.iso
echo "Created build/NBU-OS.utm; configure Standard PC (Q35 + ICH9) in UTM if available"


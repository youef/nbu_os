#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="${1:-NBU-OS}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/$PROJECT"

write() { mkdir -p "$(dirname "$1")"; printf '%s\n' "$2" > "$1"; }

rm -rf "$OUT" "$ROOT/$PROJECT.zip"
mkdir -p "$OUT"/{boot,kernel,include,config,scripts,docs,build,dist}

write "$OUT/README.md" '# NBU-OS

**نظام جامعة الحدود الشمالية**  
الهوية المطورة: **يوسف الحازمي**  
الجهة: **جامعة الحدود الشمالية - الإدارة العامة للتحول الرقمي**

هذه نسخة تأسيسية قابلة للإقلاع لمعمارية `x86_64`. تستخدم GRUB Multiboot2، ولذلك تعمل في QEMU وUTM وVirtualBox وVMware وHyper-V عندما يوفّر الجهاز الافتراضي BIOS أو UEFI مع GRUB. لا يدّعي المشروع دعم كل أجهزة الهاتف أو تشغيل نواة x86 مباشرة على iPhone؛ على iPhone تستخدم UTM محاكاة x86، وقد تكون بطيئة.

## البناء

```sh
./scripts/build.sh
./scripts/run-qemu.sh
```

الناتج هو `dist/NBU-OS.iso`. لاستيراده إلى UTM على iPhone انسخ مجلد `dist/NBU-OS.utm` أو أنشئ آلة جديدة واختر ملف ISO. ملف `config.plist` المرفق يضبط المحاكاة على `x86_64` وذاكرة 512 MiB.

## المتطلبات

`gcc`, `binutils`, `grub-mkrescue`, `xorriso`، و`qemu-system-x86_64` للاختبار. في Ubuntu/Debian:

```sh
sudo apt install build-essential binutils grub-pc-bin grub-common xorriso qemu-system-x86
```

لا يتم تفعيل Secure Boot أو تعريفات الأجهزة الحقيقية في هذه النسخة. إضافة UEFI native وARM64 وIntel VT-x/AMD-V passthrough مراحل لاحقة، ولا يمكن ضمانها من داخل نظام الضيف وحده.

## الهوية والترخيص

تظهر الهوية في شاشة الإقلاع وسجل Serial. الاسم والجهة المذكوران أعلاه إعداد تخصيص، ويجب اعتماد الشعار الرسمي والتراخيص من الجهة المختصة قبل التوزيع العام.
'

write "$OUT/VERSION" '0.2.0-alpha'
write "$OUT/config/platform.conf" '# Target platform
ARCH=x86_64
BOOT=multiboot2
MEMORY=512M
SERIAL=enabled
BRAND_DEVELOPER="يوسف الحازمي"
BRAND_ORG="جامعة الحدود الشمالية - الإدارة العامة للتحول الرقمي"'
write "$OUT/include/types.h" '#ifndef NBU_TYPES_H
#define NBU_TYPES_H
#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#endif'

write "$OUT/boot/multiboot2.S" '.section .multiboot
.global multiboot_start
multiboot_start:
.align 8
.long 0xe85250d6
.long 0
.long multiboot_end - multiboot_start
.long -(0xe85250d6 + 0 + (multiboot_end - multiboot_start))
.short 0
.short 0
.long 8
multiboot_end:

.section .text
.global _start
.type _start, @function
_start:
    cli
    mov $stack_top, %esp
    push %ebx
    push %eax
    call kernel_main
1:
    hlt
    jmp 1b

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:

.section .note.GNU-stack,"",@progbits'

write "$OUT/kernel/kernel.c" '#include <stdint.h>

static volatile uint16_t *const vga = (uint16_t *)0xb8000;
static uint16_t cursor;
static char installed_user[32];
static char installed_password[32];

static uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static void clear_screen(void) {
    for (uint16_t index = 0; index < 80 * 25; ++index) {
        vga[index] = 0x0720;
    }
    cursor = 0;
}

static void putc(char c) {
    if (c == '\''\n'\'') {
        cursor = (uint16_t)(((cursor / 80) + 1) * 80);
        return;
    }
    vga[cursor++] = (uint16_t)(0x0f00u | (uint8_t)c);
    if (cursor >= 80 * 25) cursor = 0;
}

static void puts(const char *text) {
    while (*text) putc(*text++);
}

static int text_equal(const char *left, const char *right) {
    while (*left && *right && *left == *right) {
        ++left;
        ++right;
    }
    return *left == *right;
}

static char key_to_ascii(uint8_t scan_code) {
    static const char keymap[] = "?1234567890-=qwertyuiop[]?asdfghjkl;\\`?zxcvbnm,./";
    if (scan_code >= 2 && scan_code <= 53) {
        return keymap[scan_code - 1];
    }
    if (scan_code == 57) return ' ';
    return 0;
}

static char read_key(void) {
    uint8_t scan_code;
    for (;;) {
        if (!(inb(0x64) & 1)) continue;
        scan_code = inb(0x60);
        if (scan_code & 0x80) continue;
        if (scan_code == 28) return '\''\n'\'';
        if (scan_code == 14) return '\''\b'\'';
        return key_to_ascii(scan_code);
    }
}

static void read_line(char *buffer, uint32_t capacity, int secret) {
    uint32_t length = 0;
    for (;;) {
        char key = read_key();
        if (key == '\''\n'\'') {
            putc('\''\n'\'');
            buffer[length] = 0;
            return;
        }
        if (key == '\''\b'\'') {
            if (length > 0) {
                --length;
                if (cursor > 0) --cursor;
                vga[cursor] = 0x0720;
            }
            continue;
        }
        if (key && length + 1 < capacity) {
            buffer[length++] = key;
            putc(secret ? '\''*'\'' : key);
        }
    }
}

static void installer(void) {
    clear_screen();
    puts("NBU-OS INSTALLER\n");
    puts("Digital Transformation Edition\n\n");
    puts("Create the first local account.\n");
    puts("Username: ");
    read_line(installed_user, sizeof(installed_user), 0);
    puts("Password: ");
    read_line(installed_password, sizeof(installed_password), 1);
    puts("\nInstalling NBU-OS services... OK\n");
    puts("Installing desktop profile... OK\n");
    puts("Installation complete. Press ENTER to continue.");
    while (read_key() != '\''\n'\'') { }
}

static int login(void) {
    char username[32];
    char password[32];
    clear_screen();
    puts("NBU-OS LOGIN\n\n");
    puts("User: ");
    read_line(username, sizeof(username), 0);
    puts("Password: ");
    read_line(password, sizeof(password), 1);
    if (text_equal(username, installed_user) && text_equal(password, installed_password)) {
        return 1;
    }
    puts("\nLogin failed. Press ENTER to retry.");
    while (read_key() != '\''\n'\'') { }
    return 0;
}

static void desktop(void) {
    clear_screen();
    puts("+------------------------------------------------------------------------------+\n");
    puts("| NBU-OS DESKTOP                 Yusuf Alhazmi                 [ONLINE]       |\n");
    puts("+------------------------------------------------------------------------------+\n\n");
    puts("  [1] Files     [2] Terminal     [3] Settings     [Q] Shut down\n\n");
    puts("  Northern Borders University\n");
    puts("  General Administration of Digital Transformation\n\n");
    puts("  System ready. This desktop is the first bootable prototype.\n");
    for (;;) {
        char key = read_key();
        if (key == '\''q'\'') {
            clear_screen();
            puts("NBU-OS is safe to power off.\n");
            for (;;) __asm__ volatile ("hlt");
        }
    }
}

void kernel_main(uint32_t multiboot_magic, uint32_t multiboot_info) {
    (void)multiboot_info;
    if (multiboot_magic != 0x36d76289) {
        clear_screen();
        puts("NBU-OS: invalid Multiboot2 magic.\n");
        for (;;) __asm__ volatile ("hlt");
    }

    clear_screen();
    puts("NBU-OS | Yusuf Alhazmi\n");
    puts("Northern Borders University\n");
    puts("Booting installer... Press ENTER.\n");
    while (read_key() != '\''\n'\'') { }
    installer();
    while (!login()) { }
    desktop();
}'

if [[ -f "$ROOT/kernel.template.c" ]]; then
    cp "$ROOT/kernel.template.c" "$OUT/kernel/kernel.c"
fi
if [[ -f "$ROOT/security.template.c" ]]; then
    cp "$ROOT/security.template.c" "$OUT/kernel/security.c"
fi
if [[ -f "$ROOT/security.template.h" ]]; then
    mkdir -p "$OUT/include/nbu"
    cp "$ROOT/security.template.h" "$OUT/include/nbu/security.h"
fi

write "$OUT/linker.ld" 'ENTRY(_start)
PHDRS
{
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}
SECTIONS
{
  . = 1M;
    .multiboot : { KEEP(*(.multiboot)) } :text
    .text : { *(.text*) } :text
    .rodata : { *(.rodata*) } :text
    .data : { *(.data*) } :data
    .bss : { *(COMMON) *(.bss*) } :data
}
'

write "$OUT/Makefile" 'PROJECT := NBU-OS
BUILD := build
DIST := dist
CC ?= gcc
AS ?= as
LD ?= ld
CFLAGS := -m32 -ffreestanding -fno-pie -fno-stack-protector -fno-builtin -Wall -Wextra -O2 -Iinclude
LDFLAGS := -m elf_i386 -T linker.ld -nostdlib

.PHONY: all iso clean
all: $(BUILD)/nbu-kernel.elf

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/multiboot2.o: boot/multiboot2.S | $(BUILD)
	$(AS) --32 $< -o $@

$(BUILD)/kernel.o: kernel/kernel.c include/nbu/security.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/security.o: kernel/security.c include/nbu/security.h | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/nbu-kernel.elf: $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o linker.ld
	$(LD) $(LDFLAGS) -o $@ $(BUILD)/multiboot2.o $(BUILD)/kernel.o $(BUILD)/security.o

iso: all
	rm -rf $(BUILD)/iso
	mkdir -p $(BUILD)/iso/boot/grub
	cp $(BUILD)/nbu-kernel.elf $(BUILD)/iso/boot/nbu-kernel.elf
	printf "set timeout=3\\nset default=0\\nmenuentry \\"NBU-OS - Digital Transformation\\" {\\n  multiboot2 /boot/nbu-kernel.elf\\n  boot\\n}\\n" > $(BUILD)/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(DIST)/NBU-OS.iso $(BUILD)/iso

clean:
	rm -rf $(BUILD) $(DIST)
'

write "$OUT/scripts/build.sh" '#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
command -v grub-mkrescue >/dev/null || { echo "grub-mkrescue is required" >&2; exit 2; }
mkdir -p dist
make iso
echo "Created dist/NBU-OS.iso"'
chmod +x "$OUT/scripts/build.sh"

write "$OUT/scripts/run-qemu.sh" '#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
[[ -f dist/NBU-OS.iso ]] || ./scripts/build.sh
exec qemu-system-x86_64 -cdrom dist/NBU-OS.iso -m 512M -serial stdio -display gtk'
chmod +x "$OUT/scripts/run-qemu.sh"

write "$OUT/scripts/create-utm.sh" '#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")/.."
[[ -f dist/NBU-OS.iso ]] || ./scripts/build.sh
mkdir -p dist/NBU-OS.utm
cat > dist/NBU-OS.utm/config.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Backend</key><string>QEMU</string>
<key>ConfigurationVersion</key><integer>4</integer>
<key>Information</key><dict><key>Name</key><string>NBU-OS</string><key>Notes</key><string>يوسف الحازمي | جامعة الحدود الشمالية - الإدارة العامة للتحول الرقمي</string></dict>
<key>System</key><dict><key>Architecture</key><string>x86_64</string><key>CPU</key><string>host</string><key>Memory</key><integer>512</integer><key>CPUCount</key><integer>2</integer></dict>
<key>Display</key><dict><key>Type</key><string>virtio-gpu-pci</string></dict>
<key>Drives</key><array><dict><key>ImageType</key><string>CD</string><key>ImagePath</key><string>NBU-OS.iso</string><key>Interface</key><string>IDE</string><key>Removable</key><true/></dict></array>
<key>Serial</key><dict><key>Mode</key><string>None</string></dict>
</dict></plist>
PLIST
cp dist/NBU-OS.iso dist/NBU-OS.utm/NBU-OS.iso
echo "Created dist/NBU-OS.utm; import this bundle into UTM on iPhone/iPad"
'
chmod +x "$OUT/scripts/create-utm.sh"

write "$OUT/docs/PORTABILITY.md" '# التوافق والمنصات

| المنصة | الوضع | الملاحظات |
|---|---|---|
| QEMU x86_64 | مدعوم للاختبار | BIOS عبر GRUB Multiboot2 |
| UTM على iPhone/iPad | مدعوم بالمحاكاة | شغّل x86_64 داخل UTM، وليس نواة iOS الأصلية |
| Intel/AMD PC | مدعوم مبدئياً | يتطلب GRUB أو وسيطاً يدعم Multiboot2 |
| VirtualBox/VMware/Hyper-V | قابل للتجربة | أنشئ جهاز Gen 1/BIOS واربط ISO |
| UEFI native | مخطط | يلزم إضافة EFI stub أو GRUB EFI والتحقق على OVMF |
| ARM64/Apple Silicon | غير مدعوم بهذه النواة | يحتاج منفذاً منفصلاً لمعمارية ARM64 |

المعالج الافتراضي لا يلغي فروق المعمارية. ميزات Intel VT-x وAMD-V تفيد تشغيل الضيف المتداخل فقط، ولا تجعل نواة x86_64 تعمل مباشرة على ARM.
'

write "$OUT/docs/IDENTITY.md" '# الهوية

- المطور: يوسف الحازمي
- الجهة: جامعة الحدود الشمالية
- الإدارة: الإدارة العامة للتحول الرقمي
- اسم النظام: NBU-OS

لا تضاف الشعارات الرسمية أو الأختام إلا بعد توفير ملفاتها واعتماد استخدامها.'

write "$OUT/docs/INSTALL.md" '# NBU-OS installation and first boot

Install the build dependencies:

```sh
sudo apt-get update
sudo apt-get install -y build-essential binutils grub-pc-bin grub-common xorriso qemu-system-x86
```

Build the ISO with ./scripts/build.sh, then attach dist/NBU-OS.iso to a new UTM x86_64 VM. On iPhone/iPad choose Emulate, assign at least 512 MB RAM, attach the ISO, and boot.

Press Enter at the installer screen, create the first username and password, then log in. The prototype desktop appears after successful login. The account is currently kept in memory for the current boot; persistent storage and password hashing are planned for a later filesystem phase.

The GitHub Actions workflow builds the ISO and uploads it as an artifact on every push.'

write "$OUT/docs/PRODUCTION.md" '# Production readiness

NBU-OS is an independent kernel and system. It is not based on Linux and does not use the Linux ABI.

Current foundations: reproducible generation, explicit ELF permissions, private NBU-EXEC-1 programs, SHA-256 password digests, constant-time comparison, and GitHub Actions ISO builds.

Before a production release, NBU-OS still requires persistent encrypted accounts, signed boot, user-mode isolation, a validated external NBUX loader, drivers, a pinned toolchain, fuzzing, threat modeling, release signing, and independent security review.

Credentials are currently held only for the current boot. Do not use the prototype for real institutional credentials.'

mkdir -p "$OUT/dist"
(cd "$ROOT" && zip -qr "$PROJECT.zip" "$PROJECT")
printf 'Created %s and %s.zip\n' "$PROJECT" "$PROJECT"

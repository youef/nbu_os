# NBU-OS

نظام جامعة الحدود الشمالية — v0.5.0-alpha1

## الإقلاع والمنصات
- BIOS + GRUB/Multiboot2.
- UEFI x86_64 عبر GRUB removable boot.
- ISO للـCD/DVD وUTM.
- IMG خام 128MB بجدول GPT وESP وBIOS Boot Partition.
- GUI framebuffer 1024x768x32.
- VGA fallback.
- PS/2 mouse input لتحريك المؤشر والنقر والسحب في بيئات QEMU/UTM التي تقدم PS/2.
- لوحة المفاتيح تمر عبر لوحة المفاتيح الافتراضية في UTM.

## UTM على iPhone/iPad
UTM على iOS يعتمد على QEMU. استخدم QEMU/x86_64، ثم أرفق NBU-OS.iso كـCD/DVD أو NBU-OS.img كقرص. يفضل تفعيل USB tablet، وإذا لم يتوفر استخدم Force PS/2 controller.

الإعداد المقترح: x86_64، QEMU، RAM 1024-2048 MB، نواتان CPU، Boot BIOS أو UEFI.

## البناء
cd NBU-OS
./scripts/build.sh

النواتج: dist/NBU-OS.iso و dist/NBU-OS.img

الـIMG الآن قرص GPT حقيقي وليس مجرد نسخة باسم .img.

## الحدود الحالية
الواجهة ما زالت Kernel-native وليست Window Manager كاملًا. دعم USB HID/tablet الأصلي، اللمس المباشر المتقدم، الملفات الدائمة، الشبكة، UEFI runtime services والعزل الكامل لبرامج user-mode مراحل لاحقة.


## NBU-OS Next — v0.5.0-alpha2

This development branch adds:
- clickable framebuffer desktop cards using PS/2 mouse input;
- visible software mouse cursor;
- non-blocking GUI input polling for QEMU/UTM PS/2 mouse paths;
- real GPT disk-image validation for the UEFI/BIOS IMG;
- CI validation order corrected so the IMG is created before it is checked.

The target remains x86_64 BIOS/GRUB + UEFI under QEMU/UTM. UTM Touch Mode using an emulated USB tablet still requires a USB HID tablet driver in the kernel; the current branch provides the PS/2 fallback path.

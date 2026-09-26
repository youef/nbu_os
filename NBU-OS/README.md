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

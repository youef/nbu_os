# NBU-OS

نظام جامعة الحدود الشمالية — **v0.5.0-alpha4**

## الإقلاع والمنصات

- BIOS + GRUB/Multiboot2.
- UEFI x86_64 عبر GRUB removable boot.
- ISO للـCD/DVD وUTM.
- IMG خام 128MB بجدول GPT وESP وBIOS Boot Partition.
- **UTM SE IMG مستقل** بجدول MBR وGRUB i386-pc ومناسب لـQEMU/UTM SE.
- GUI framebuffer 1024x768x32.
- VGA fallback.
- PS/2 mouse input لتحريك المؤشر والنقر في بيئات QEMU/UTM.
- لوحة المفاتيح تمر عبر لوحة المفاتيح الافتراضية في UTM.

## UTM SE على iPhone/iPad

الإصدار alpha4 يضيف **حزمة UTM جاهزة للاستيراد**:

- المعمارية: x86_64.
- QEMU.
- Standard PC / i440FX.
- Legacy BIOS — UEFI مغلق.
- 1GB RAM.
- 2 CPU.
- قرص IDE داخلي.
- لا يوجد CD/ISO داخل الحزمة.
- القرص المضمّن هو `NBU-OS-UTM.img` نفسه.
- الحزمة النهائية: `dist/NBU-OS.utm`.
- الحزمة المضغوطة: `dist/NBU-OS-UTM.utm.zip`.

يمكن لـUTM استيراد ملف `.utm` كآلة افتراضية، كما يدعم رابط `utm://downloadVM` تنزيل ZIP يحتوي على حزمة `.utm` ثم استخراجها واستيرادها.

## البناء

    cd NBU-OS
    ./scripts/build.sh
    ./scripts/build-utm-img.sh
    ./scripts/create-utm.sh
    cd dist
    zip -qr NBU-OS-UTM.utm.zip NBU-OS.utm

النواتج:

- `dist/NBU-OS.iso`
- `dist/NBU-OS.img`
- `dist/NBU-OS-UTM.img`
- `dist/NBU-OS.utm/`
- `dist/NBU-OS-UTM.utm.zip`

## ملاحظات UTM

UTM SE على iOS يدعم x86_64. وللأنظمة x86_64/i386 القديمة توصي وثائق UTM باستخدام Standard PC المبني على i440FX + PIIX بدل نموذج 2009 الافتراضي. كما أن ترتيب الأقراص يحدد ترتيب الإقلاع.

هذه الحزمة مصممة بحيث يكون القرص الداخلي هو جهاز الإقلاع الوحيد، لتجنب مشكلة الإقلاع من ISO.

## الحدود الحالية

الواجهة ما زالت Kernel-native وليست Window Manager كاملًا. دعم USB HID/tablet الأصلي، اللمس المباشر المتقدم، الملفات الدائمة، الشبكة، UEFI runtime services والعزل الكامل لبرامج user-mode مراحل لاحقة.

## v0.5.0-alpha4

- إصلاح حزمة UTM القديمة التي كانت تحتوي ISO بدل قرص UTM.
- تضمين `NBU-OS-UTM.img` الحقيقي داخل `NBU-OS.utm`.
- Legacy BIOS + MBR + GRUB i386-pc.
- x86_64 + i440FX + IDE.
- إزالة CD/ISO من حزمة UTM الجاهزة.
- إضافة SHA256 داخل الحزمة.
- تجهيز ZIP للاستيراد المباشر في UTM.

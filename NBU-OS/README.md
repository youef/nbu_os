# NBU-OS

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


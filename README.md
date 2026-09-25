# NBU-OS

مولد نسخة تأسيسية لنظام جامعة الحدود الشمالية، مخصصة باسم **يوسف الحازمي** للـ **إدارة العامة للتحول الرقمي**.

## التشغيل السريع

```sh
./build.sh
./check_iso.sh
```

ينتج `NBU-OS/build/NBU-OS.iso` و`NBU-OS/build/NBU-OS.img`. ISO مخصص للإقلاع عبر BIOS وGRUB Multiboot2؛ IMG نسخة hybrid raw تُختبر كقرص BIOS. النواة `x86_64` مستقلة وليست Linux، وتعمل على UTM SE بالمحاكاة. UEFI وARM64 غير مدعومين في هذه النسخة.

للبناء والتحقق نفّذ `./build.sh` ثم `./check_iso.sh`. في UTM SE على iPhone/iPad اختر `x86_64` و`Standard PC (Q35 + ICH9)` وذاكرة `2048 MB` وBIOS، ثم أرفق `NBU-OS.iso` كـ CD/DVD واجعل الإقلاع منه. الشبكة غير مطلوبة حاليًا.

المتطلبات وطريقة التوافق موثقة داخل [NBU-OS/README.md](NBU-OS/README.md) و[NBU-OS/docs/PORTABILITY.md](NBU-OS/docs/PORTABILITY.md).

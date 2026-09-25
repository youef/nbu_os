# NBU-OS

مولد نسخة تأسيسية لنظام جامعة الحدود الشمالية، مخصصة باسم **يوسف الحازمي** للـ **إدارة العامة للتحول الرقمي**.

## التشغيل السريع

```sh
./build_nbu.sh
cd NBU-OS
./scripts/build.sh
./scripts/create-utm.sh
```

ينتج `NBU-OS/dist/NBU-OS.iso` وحزمة `NBU-OS/dist/NBU-OS.utm` للاستيراد إلى UTM على iPhone/iPad. النواة الحالية `x86_64-hosted/i386-kernel` وتعمل بالمحاكاة على UTM؛ دعم ARM64 وUEFI native ما زال مرحلة لاحقة.

المتطلبات وطريقة التوافق موثقة داخل [NBU-OS/README.md](NBU-OS/README.md) و[NBU-OS/docs/PORTABILITY.md](NBU-OS/docs/PORTABILITY.md).

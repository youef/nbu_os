# NBU-OS على UTM iOS

## ISO
أنشئ VM جديدة: QEMU، x86_64، 1-2 GB RAM، نواتان CPU. أضف NBU-OS.iso كمحرك CD/DVD ثم شغّل.

## IMG
أضف NBU-OS.img كقرص Drive. النسخة تحتوي GPT مع EFI System Partition وBIOS Boot Partition، لذلك تستهدف BIOS وUEFI.

## لوحة المفاتيح
UTM على iOS يوفر لوحة مفاتيح على الشاشة ويمكنه إرسال الإدخال للضيف. استخدم زر لوحة المفاتيح في شريط UTM لإظهارها.

## اللمس والسحب
Touch Mode في UTM يرسل موضع الإدخال المطلق إلى الضيف عندما يكون USB tablet متاحًا. عند عدم توفره استخدم Force PS/2 controller. NBU-OS يحتوي PS/2 mouse كمسار احتياطي.

النقر والسحب يعتمد على أن UTM يرسل أحداث mouse/tablet للضيف؛ لا يستطيع نظام التشغيل قراءة لمس iPhone مباشرة.

## الأداء
UTM SE يستخدم محاكاة أبطأ بدون JIT، لذلك قد يكون أبطأ من UTM الذي يستطيع استخدام JIT.

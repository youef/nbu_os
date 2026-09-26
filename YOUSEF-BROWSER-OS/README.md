# YOUSEF Browser OS

نظام خفيف مخصص للتصفح فقط، مبني كصورة x86_64 قابلة للتشغيل على UTM SE.

## الهدف
- تشغيل متصفح Firefox ESR مباشرة.
- واجهة بسيطة باسم YOUSEF Browser OS.
- شبكة Wi-Fi/Ethernet عبر NetworkManager.
- لا توجد أدوات تطوير أو خدمات غير لازمة.
- إقلاع BIOS/Legacy مناسب لمحاكاة x86_64 في UTM SE.
- صورة RAW disk باسم `YOUSEF-Browser-OS.img`.

## UTM SE
- Architecture: x86_64
- Machine: Standard PC / Q35 أو PC
- RAM: 2048 MB
- CPU: 2 cores
- Boot: BIOS
- Disk: `YOUSEF-Browser-OS.img`
- Network: Shared/NAT

> الإصدار الأول مخصص للتصفح. دعم UEFI/ARM64 يمكن إضافته لاحقًا.

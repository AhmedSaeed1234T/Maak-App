@echo off
chcp 65001 >nul
echo جاري سحب التغييرات من الـ remote...
git pull --no-rebase
if %errorlevel% neq 0 (
    echo حدث خطأ في الـ pull. جاري المحاولة مع rebase...
    git pull --rebase
)
if %errorlevel% equ 0 (
    echo تم سحب التغييرات بنجاح!
    echo جاري رفع التغييرات...
    git push
    if %errorlevel% equ 0 (
        echo تم رفع التغييرات بنجاح!
    ) else (
        echo فشل رفع التغييرات. يرجى التحقق من الأخطاء أعلاه.
    )
) else (
    echo فشل سحب التغييرات. قد تكون هناك تعارضات تحتاج إلى حل يدوي.
    pause
)


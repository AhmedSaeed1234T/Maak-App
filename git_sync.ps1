# Git Sync Script
Write-Host "جاري سحب التغييرات من الـ remote..." -ForegroundColor Yellow
git pull --no-rebase

if ($LASTEXITCODE -ne 0) {
    Write-Host "حدث خطأ في الـ pull. جاري المحاولة مع rebase..." -ForegroundColor Yellow
    git pull --rebase
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "تم سحب التغييرات بنجاح!" -ForegroundColor Green
    Write-Host "جاري رفع التغييرات..." -ForegroundColor Yellow
    git push
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "تم رفع التغييرات بنجاح!" -ForegroundColor Green
    } else {
        Write-Host "فشل رفع التغييرات. يرجى التحقق من الأخطاء أعلاه." -ForegroundColor Red
    }
} else {
    Write-Host "فشل سحب التغييرات. قد تكون هناك تعارضات تحتاج إلى حل يدوي." -ForegroundColor Red
    Write-Host "اضغط أي مفتاح للمتابعة..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}


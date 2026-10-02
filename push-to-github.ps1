Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Pushing Career Link project to GitHub with Token..." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

Write-Host "[1/4] Initializing Git..." -ForegroundColor Yellow
git init

Write-Host "[2/4] Adding all files..." -ForegroundColor Yellow
git add .

Write-Host "[3/4] Committing..." -ForegroundColor Yellow
git commit -m "Career Link: Full-stack job portal (Vercel Deployable)"

Write-Host "[4/4] Setting main branch & pushing with authentication token..." -ForegroundColor Yellow
git branch -M main
git push -u https://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@github.com/Rushi4242/careerlink.git main --force

Write-Host "========================================================" -ForegroundColor Green
Write-Host "Push complete! Check your repository:" -ForegroundColor Green
Write-Host "https://github.com/Rushi4242/careerlink" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

Write-Host "Pushing Career Link project to GitHub..." -ForegroundColor Cyan

Set-Location -Path $PSScriptRoot

git add .
git commit -m "Career Link: Full-stack job portal (Vercel Deployable)"
git branch -M main
git remote remove origin 2>$null
git remote add origin https://github.com/Rushi4242/careerlink.git
git push -u origin main --force

Write-Host "Done!" -ForegroundColor Green

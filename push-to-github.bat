@echo off
echo ========================================================
echo Pushing Career Link project to GitHub...
echo Target: https://github.com/Rushi4242/careerlink.git
echo ========================================================

cd /d "%~dp0"

git add .
git commit -m "Career Link: Full-stack job portal (Vercel Deployable)"
git branch -M main
git remote remove origin 2>nul
git remote add origin https://github.com/Rushi4242/careerlink.git
git push -u origin main --force

echo Done!
pause

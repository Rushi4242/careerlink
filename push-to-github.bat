@echo off
echo ========================================================
echo Pushing Career Link project to GitHub with Token...
echo ========================================================

cd /d "%~dp0"

echo [1/4] Initializing Git...
git init

echo [2/4] Adding all files...
git add .

echo [3/4] Committing...
git commit -m "Career Link: Full-stack job portal (Vercel Deployable)"

echo [4/4] Setting main branch & pushing with authentication token...
git branch -M main
git push -u https://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@github.com/Rushi4242/careerlink.git main --force

echo ========================================================
echo Push complete! Check your repository:
echo https://github.com/Rushi4242/careerlink
echo ========================================================
pause

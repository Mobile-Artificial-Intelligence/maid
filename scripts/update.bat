@echo off
:: Get the number of commits
for /f %%i in ('git rev-list --count HEAD') do set commit_count=%%i

:: Update the pubspec.yaml file with the new build number
powershell -Command "(gc ../pubspec.yaml) -replace 'version: (.*)\+.*', 'version: $1+%commit_count%' | Out-File -encoding ASCII ../pubspec.yaml"

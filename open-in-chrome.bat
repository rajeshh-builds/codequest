@echo off
echo ==============================================================
echo [CodeQuest] Launching Platform Directly in Google Chrome
echo Target URL: http://localhost:8080/codequest
echo ==============================================================

start chrome "http://localhost:8080/codequest" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Chrome executable not in PATH, launching in default browser...
    start "" "http://localhost:8080/codequest"
)
echo [OK] CodeQuest opened in browser.

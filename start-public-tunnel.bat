@echo off
echo ==============================================================
echo [CodeQuest] Launching Public Live Cloudflare Tunnel
echo Traffic will be securely forwarded from localhost:8080
echo ==============================================================

if not exist "cloudflared.exe" (
    echo Downloading cloudflared helper...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' -OutFile 'cloudflared.exe' -UseBasicParsing"
)

echo Starting tunnel on http://localhost:8080...
cloudflared.exe tunnel --protocol http2 --url http://localhost:8080
pause

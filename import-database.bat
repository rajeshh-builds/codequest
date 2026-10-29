@echo off
echo ==============================================================
echo [CodeQuest] Initializing Database Schema in MySQL
echo ==============================================================
echo.
echo Please enter your MySQL root password when prompted:
echo.
mysql -u root -p -e "source database/schema.sql"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==============================================================
    echo [SUCCESS] codequest_db and seed tables created successfully!
    echo ==============================================================
) else (
    echo.
    echo [ERROR] Failed to import database. Check your MySQL password.
)
pause

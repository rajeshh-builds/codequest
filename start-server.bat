@echo off
setlocal
echo ==============================================================
echo [CodeQuest] Launching Application on Apache Tomcat 11
echo ==============================================================

if not exist "%JAVA_HOME%\bin\java.exe" (
    if exist "C:\Program Files\Java\jdk-25.0.4.1\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-25.0.4.1"
    ) else if exist "C:\Program Files\Java\latest\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Java\latest"
    )
)

if "%CATALINA_HOME%"=="" (
    set "CATALINA_HOME=C:\Users\samal\Downloads\apache-tomcat-11.0.26-windows-x64\apache-tomcat-11.0.26"
)

set "CATALINA_OPTS=-Xms256m -Xmx1024m -XX:+UseG1GC -Dfile.encoding=UTF-8"
echo Java Runtime : %JAVA_HOME%
echo Tomcat Server: %CATALINA_HOME%
echo JVM Tuning   : %CATALINA_OPTS%
echo.

echo [1/3] Compiling and Packaging codequest.war...
call "%~dp0build.bat" --no-pause
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed. Aborting startup.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] Preparing deployment in Tomcat webapps...
netstat -ano | findstr /R ":8080 .*LISTENING" >nul
if %ERRORLEVEL% EQU 0 (
    echo Port 8080 is currently occupied. Stopping existing Tomcat instance...
    call "%CATALINA_HOME%\bin\shutdown.bat" >nul 2>&1
    ping 127.0.0.1 -n 3 >nul
)

if exist "%CATALINA_HOME%\webapps\codequest" (
    rmdir /s /q "%CATALINA_HOME%\webapps\codequest" >nul 2>&1
)
copy /Y "%~dp0codequest.war" "%CATALINA_HOME%\webapps\codequest.war" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy codequest.war to %CATALINA_HOME%\webapps\
    pause
    exit /b %ERRORLEVEL%
)
echo [OK] Fresh codequest.war deployed successfully.

echo.
echo [3/3] Starting Tomcat Server...
call "%CATALINA_HOME%\bin\startup.bat"

echo.
echo ==============================================================
echo Waiting for Tomcat to initialize...
echo The CodeQuest platform is available at:
echo URL: http://localhost:8080/codequest
echo ==============================================================
ping 127.0.0.1 -n 5 >nul
start chrome "http://localhost:8080/codequest" 2>nul || start "" "http://localhost:8080/codequest"

echo Server process started. Check the Tomcat console window for live logs.
pause

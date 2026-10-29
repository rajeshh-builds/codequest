@echo off
setlocal
echo ==============================================================
echo [CodeQuest] Compiling ^& Packaging Platform WAR Archive
echo ==============================================================

if not exist "%JAVA_HOME%\bin\jar.exe" (
    if exist "C:\Program Files\Java\jdk-25.0.4.1\bin\jar.exe" (
        set "JAVA_HOME=C:\Program Files\Java\jdk-25.0.4.1"
    ) else if exist "C:\Program Files\Java\latest\bin\jar.exe" (
        set "JAVA_HOME=C:\Program Files\Java\latest"
    )
)
set "PATH=%JAVA_HOME%\bin;%PATH%"

if not exist "WebContent\WEB-INF\classes" mkdir "WebContent\WEB-INF\classes"

echo [1/2] Compiling Java Source Files using JDK at: %JAVA_HOME%...
javac -cp "WebContent\WEB-INF\lib\*" -d "WebContent\WEB-INF\classes" src\com\codequest\model\*.java src\com\codequest\util\*.java src\com\codequest\servlet\*.java
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed!
    if /i not "%~1"=="--no-pause" pause
    exit /b %ERRORLEVEL%
)
echo [OK] Compilation successful. All classes generated in WebContent\WEB-INF\classes

echo Copying configuration properties into WebContent\WEB-INF\classes...
copy /Y "%~dp0db.properties" "WebContent\WEB-INF\classes\db.properties" >nul

echo [2/2] Packaging codequest.war...
jar cvf codequest.war -C WebContent .
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] WAR packaging failed!
    if /i not "%~1"=="--no-pause" pause
    exit /b %ERRORLEVEL%
)

echo ==============================================================
echo [SUCCESS] codequest.war created successfully!
echo To deploy: Copy 'codequest.war' into your Apache Tomcat 10.1/11 'webapps/' directory
echo Or start Tomcat and open: http://localhost:8080/codequest
echo ==============================================================
if /i not "%~1"=="--no-pause" pause

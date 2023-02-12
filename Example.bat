@echo off

:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

::ENTER YOUR CODE BELOW:

set /p "NAME=Enter New PC name: "
set SSID="Example WiFi SSID"
set PSK="Example WiFi PW"
set LocalAdminPW="Some Password"
set AgentMSI="Some.MSI"
set LocationID="1234567"
set OfficeVersion="ProPlus64"
set DomainJoined=true
set DomainName="Some.Domain"
set AdminPass="SomeDApass"
set ServerAddress="https://server.automate.what/automate"
set ServerPass="SomeServerPW"

ECHO "Setting Execution Policy"
powershell.exe -Command "Set-ExecutionPolicy Bypass -Force"

ECHO "Starting setup"
IF %DomainJoined%==true (powershell.exe -File %~dp0Invoke-BaseSetup.ps1 -SSID %SSID% -PSK %PSK% -LocalAdminPW %LocalAdminPW% -AgentMSI %AgentMSI% -LocationID %LocationID% -NewName %NAME% -OfficeVersion %OfficeVersion% -ServerAddress %ServerAddress% -DomainJoined -DomainName %DomainName% -AdminPass %AdminPass% -PresentWorkingDir %~dp0) ELSE (powershell.exe -File %~dp0Invoke-BaseSetup.ps1 -SSID %SSID% -PSK %PSK% -LocalAdminPW %LocalAdminPW% -AgentMSI %AgentMSI% -LocationID %LocationID% -NewName %NAME% -OfficeVersion %OfficeVersion% -ServerAddress %ServerAddress% -ServerPass %ServerPass% -PresentWorkingDir %~dp0)

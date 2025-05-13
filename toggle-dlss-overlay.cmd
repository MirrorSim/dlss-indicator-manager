:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NVIDIA DLSS Indicator Manager - Version 1.1
:: Created by: mirrorsim
:: 
:: Description:
::   Controls the NVIDIA DLSS overlay that displays technical information
::   during gameplay (DLL version, mode, resolution, etc.)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal EnableDelayedExpansion
color 07
title NVIDIA DLSS Indicator Manager - Version 1.1

:: Configure console appearance
mode con: cols=85 lines=35

:: Setup colored text output
for /F %%a in ('echo prompt $E^| cmd /q') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "RESET=%ESC%[0m"

:: Enable ANSI colors for Windows 10+
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" (
    reg add "HKEY_CURRENT_USER\Console" /v "VirtualTerminalLevel" /t REG_DWORD /d "1" /f >nul 2>&1
)

::: ASCII Art Logo
set "line1=      _____  _      _____ _____   _____           _ _           _             "
set "line2=     |  __ \| |    / ____/ ____| |_   _|         | (_)         | |            "
set "line3=     | |  | | |   | (___| (___     | |  _ __   __| |_  ___ __ _| |_ ___  _ __ "
set "line4=     | |  | | |    \___ \\___ \    | | | '_ \ / _` | |/ __/ _` | __/ _ \| '__|"
set "line5=     | |__| | |____\___) |___) |  _| |_| | | | (_| | | (_| (_| | || (_) | |   "
set "line6=     |_____/|______|____/_____/  |_____|_| |_|\__,_|_|\___\__,_|\__\___/|_|   "
set "line7=                                                                              "
::set "line8=                                 by mirrorsim - v1.1                              "

::: ADMIN PRIVILEGES CHECK
:: Request admin rights required for registry modification
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorLevel% neq 0 (
    echo Requesting administrator privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    :: Create VBS script to trigger UAC prompt and restart with admin rights
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    :: Clean up and initialize environment
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

::: MAIN MENU
:menu
cls
:: Display ASCII logo in green
echo %GREEN%
echo. !line1!
echo. !line2!
echo. !line3!
echo. !line4!
echo. !line5!
echo. !line6!
echo. !line7!
::echo. !line8!
echo %RESET%
echo:      _________________________________________________________________________
echo.

::: HARDWARE DETECTION 
:: Check if NVIDIA GPU is present (required for DLSS)
set "nvidia_gpu=False"
wmic path win32_VideoController get name | find "NVIDIA" >nul 2>&1
if %errorLevel% equ 0 (
    set "nvidia_gpu=True"
) else (
    echo %RED%WARNING: No NVIDIA GPU found%RESET%
    timeout /t 2 >nul
)

::: REGISTRY STATUS CHECK
:: Check NVIDIA registry key: HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore
:: ShowDlssIndicator values:
::   0x400 (1024) = enabled, 0x0 (0) = disabled

reg query "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" >nul 2>&1
if %errorLevel% neq 0 (
    echo %GREEN%[i] DLSS indicator is not configured in registry.%RESET%
    set "current_status=Not configured"
) else (
    :: Get current registry value and determine status
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" ^| find "ShowDlssIndicator"') do set "dlss_value=%%a"
    if "!dlss_value!"=="0x400" (
        set "current_status=ACTIVE"
    ) else if "!dlss_value!"=="0x0" (
        set "current_status=DISABLED"
    ) else (
        set "current_status=CUSTOM (!dlss_value!)"
    )
)

::: DISPLAY STATUS AND MENU
:: Show system information and menu options
if "!nvidia_gpu!"=="True" (
    echo                            NVIDIA GPU Detected: %GREEN%!nvidia_gpu!%RESET%
) else (
    echo                            NVIDIA GPU Detected: %RED%!nvidia_gpu!%RESET%
)
echo.

:: Display indicator status with appropriate color
if "!current_status!"=="ACTIVE" (
    echo                            Current DLSS indicator status: %GREEN%!current_status!%RESET%
) else if "!current_status!"=="DISABLED" (
    echo                            Current DLSS indicator status: %RED%!current_status!%RESET%
) else (
    echo                            Current DLSS indicator status: %GREEN%!current_status!%RESET%
)
echo.

:: Menu options
echo                            [%GREEN%1%RESET%] Enable DLSS indicator
echo                            [%GREEN%2%RESET%] Disable DLSS indicator
echo                            [%GREEN%3%RESET%] Info
echo                            [%RED%4%RESET%] Exit
echo.
choice /C 1234 /N /M "Select an option [%GREEN%1%RESET%-%GREEN%4%RESET%]: "
::: PROCESS MENU SELECTION
:: Navigate based on user choice (must check highest to lowest due to errorlevel behavior)
if errorlevel 4 goto exit
if errorlevel 3 goto info
if errorlevel 2 goto disable
if errorlevel 1 goto enable

::: ENABLE DLSS INDICATOR
:enable
cls
echo.
echo %GREEN%   ============================================================================
echo                        ENABLING DLSS INDICATOR IN PROGRESS                     
echo    ============================================================================%RESET%
echo.

:: Set registry value to enable indicator (0x400/1024)
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" /t REG_DWORD /d 0x400 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo %GREEN%   [SUCCESS] %RESET%DLSS indicator enabled successfully!%RESET%
    echo.
    echo    The DLSS overlay will now appear in supported games.
) else (
    echo %RED%   [ERROR] Failed to enable DLSS indicator.%RESET%
    echo.
    echo    Make sure that:
    echo    - NVIDIA drivers are correctly installed
    echo    - Your graphics card supports DLSS
)
echo.
echo.
echo Press any key to return to the main menu...
pause >nul
goto menu

::: DISABLE DLSS INDICATOR
:disable
cls
echo.
echo %GREEN%   ============================================================================
echo                        DISABLING DLSS INDICATOR IN PROGRESS                     
echo    ============================================================================%RESET%
echo.

:: Set registry value to disable indicator (0x0/0)
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" /t REG_DWORD /d 0x0 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo %GREEN%   [SUCCESS] DLSS indicator disabled successfully!%RESET%
    echo.
    echo    The DLSS overlay will no longer appear in games.
) else (
    echo %RED%   [ERROR] Failed to disable DLSS indicator.%RESET%
    echo.
    echo    Make sure that:
    echo    - NVIDIA drivers are correctly installed
    echo    - Your graphics card supports DLSS
)
echo.
echo.
echo Press any key to return to the main menu...
pause >nul
goto menu

::: INFORMATION PAGE
:info
cls
echo.
echo    ============================================================================
echo                           INFORMATION ABOUT DLSS INDICATOR
echo    ============================================================================
echo.
echo %GREEN%   What is the DLSS indicator?%RESET%
echo.
echo    The %GREEN%DLSS%RESET% indicator is an overlay that appears in the bottom-left corner of the
echo    screen when DLSS is active. It displays technical information such as:
echo     - %GREEN%DLL version%RESET% in use
echo     - Current mode [%GREEN%Quality%RESET%, %GREEN%Balanced%RESET%, %GREEN%Performance%RESET%, %GREEN%Ultra Performance%RESET%]
echo     - Source and output (upscaled) resolutions
echo     - Active preset [%GREEN%A%RESET%, %GREEN%B%RESET%, %GREEN%C%RESET%, %GREEN%D%RESET%, %GREEN%E%RESET%, %GREEN%F%RESET%, %GREEN%J%RESET%, %GREEN%K%RESET%]
echo     - Frame generation stats (when enabled, appears in the top-left corner)
echo.
echo    ____________________________________________________________________________
echo.
echo %GREEN%   Registry information:%RESET%
echo.
echo    Path: HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore
echo.
echo    Key:  ShowDlssIndicator
echo.
echo    Values changed by this program:
echo     - %GREEN%0x400%RESET% (1024): DLSS indicator %GREEN%enabled%RESET%
echo     - %RED%0x0%RESET% (0): DLSS indicator %RED%disabled%RESET% (back to default)
echo.
echo.
echo Press any key to return to the main menu...
pause >nul
goto menu

::: EXIT
:exit
cls
echo.
echo Thank you for using the NVIDIA DLSS Indicator Manager.
echo Exiting...
timeout /t 2 >nul
exit

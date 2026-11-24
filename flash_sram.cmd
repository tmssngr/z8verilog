@echo off
setlocal

if not exist "%~dp0build\project.fs" (
    echo Bitstream not found: "%~dp0build\project.fs"
    echo Run a build script first.
    exit /b 1
)

rem Adjust this path if OSS CAD Suite is installed elsewhere.
call "D:\tools\oss-cad-suite\environment.bat" || exit /b 1

echo Programming SRAM (temporary until power-off)...
openFPGALoader -b tangnano9k -m "%~dp0build\project.fs"
exit /b %errorlevel%

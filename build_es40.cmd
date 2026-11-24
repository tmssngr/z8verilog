@echo off
setlocal

rem Adjust this path if OSS CAD Suite is installed elsewhere.
call "D:\tools\oss-cad-suite\environment.bat" || exit /b 1

rem Build from src so includes and ROM initialization files resolve correctly.
pushd "%~dp0src" || exit /b 1
if not exist "..\build" mkdir "..\build"
if errorlevel 1 goto :error
if exist "..\build\project.fs" del "..\build\project.fs"
if exist "..\build\project.fs" goto :error

yosys -l ../build/jtc_es40-synth.log -p "read_verilog -sv -I. SoC_es40.v top_es40.v gowin_rpll/gowin_rpll.v; synth_gowin -top top -json ../build/jtc_es40-synth.json"
if errorlevel 1 goto :error

nextpnr-himbaechel --json ..\build\jtc_es40-synth.json --write ..\build\jtc_es40-pnr.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst --freq 8 --log ..\build\jtc_es40-pnr.log
if errorlevel 1 goto :error

gowin_pack -d GW1N-9C -o ..\build\project.fs ..\build\jtc_es40-pnr.json
if errorlevel 1 goto :error

popd
echo.
echo Bitstream ready: "%~dp0build\project.fs"
echo Run flash_sram.cmd for a temporary SRAM load.
echo Run flash_embedded_flash.cmd to program embedded flash.
exit /b 0

:error
if exist "..\build\project.fs" del "..\build\project.fs"
popd
echo Build failed.
exit /b 1

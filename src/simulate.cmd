@echo off
setlocal

call C:\oss-cad-suite\environment.bat

:repeat
cls
call :simulate Alu
call :simulate Ps2Rx
call :simulate SerialTx
call :simulate SerialRx
call :simulate VbsGenerator
call :test SoC Xcf
call :test SoC srp_inc_dec
call :test SoC ld
call :test SoC alu1
call :test SoC incw_decw
call :test SoC da
call :test SoC add
call :test SoC cp
call :test SoC jp
call :test SoC jr
call :test SoC ldc
call :test SoC ldci
call :test SoC djnz
call :test SoC push_pop
call :test SoC push_pop_external
call :test SoC ret
call :test SoC ret_external
call :test SoC timer
call :test SoC isr
call :test SoC isr_external
call :test SoC_tiny u8830
call :test SoC_tiny jtc2k-isr
call :test SoC_tiny jtc2k

pause
goto :repeat
exit


:: ======================
:test
set NAME=%~1
set TEST=%~2
set INCLUDE_DIR=..\..

echo testing %TEST%
echo -------------
pushd testcases\%TEST%
iverilog -o test.o -I . -I %INCLUDE_DIR% -DBENCH -s test%NAME% %INCLUDE_DIR%\%NAME%.v %INCLUDE_DIR%\%NAME%_tb.v
if  %ERRORLEVEL% NEQ 0 (
    echo FAILURE
	popd
	goto :eof
)

vvp test.o > output.txt
if  %ERRORLEVEL% NEQ 0 (
    echo FAILURE
	type output.txt
)
popd
goto :eof


:: ======================
:simulate
set NAME=%~1
set NAME_TB=%NAME%_tb

echo %NAME%
echo -------------
if exist %NAME%.vcd del %NAME%.vcd

:: Usage: iverilog [-EiRSuvV] [-B base] [-c cmdfile|-f cmdfile]
::                 [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012] [-g<feature>]
::                 [-D macro[=defn]] [-I includedir] [-L moduledir]
::                 [-M [mode=]depfile] [-m module]
::                 [-N file] [-o filename] [-p flag=value]
::                 [-s topmodule] [-t target] [-T min|typ|max]
::                 [-W class] [-y dir] [-Y suf] [-l file] source_file(s)
iverilog -o %NAME_TB%.o -s test%NAME% %NAME%.v %NAME_TB%.v
if  %ERRORLEVEL% NEQ 0 (
    echo FAILURE
    goto continue
)
:: Usage: vvp [options] input-file [+plusargs...]
:: Options:
::  -h             Print this help message.
::  -i             Interactive mode (unbuffered stdio).
::  -l file        Logfile, '-' for <stderr>
::  -M path        VPI module directory
::  -M -           Clear VPI module path
::  -m module      Load vpi module.
::  -n             Non-interactive ($stop = $finish).
::  -N             Same as -n, but exit code is 1 instead of 0
::  -s             $stop right away.
::  -v             Verbose progress messages.
::  -V             Print the version information.
vvp %NAME_TB%.o > %NAME%.txt
type %NAME%.txt

:continue
echo:
goto :eof

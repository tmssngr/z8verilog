setlocal

call C:\oss-cad-suite\environment.bat

yosys.exe -s synth.ys  > yosys.log  2>&1
type yosys.log
pause

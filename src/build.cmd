setlocal

call C:\oss-cad-suite\environment.bat
set NAME=pwm
set SYNTH_JSON=%NAME%-synth.json
set PNR_JSON=%NAME%-pnr.json

yosys.exe -p "read_verilog top.v SoC.v Alu.v; synth_gowin -top top -json z8verilog.json" > log2.txt
pause

nextpnr-gowin --json %SYNTH_JSON% --write %PNR_JSON% --freq 27 --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst tangnano9k.cst
pause

gowin_pack -d GW1N-9C -o %NAME%.fs %PNR_JSON%
pause

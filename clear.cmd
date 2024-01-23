call del *.fs
call del *.history
call del *.json
call del *.o
call del *.vcd
exit

:del
if exist %~1 del %~1
goto :eof

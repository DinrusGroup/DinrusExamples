ruladaex
dmd -ofclock.exe main clock -L/exet:nt/su:windows:5.0 
upx clock.exe
clock
pause
del *.map *.obj
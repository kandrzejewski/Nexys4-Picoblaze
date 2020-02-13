@echo off
echo Picoblaze6 compiler batch file for Artix7 implementation.
echo param1 - memfilename.mem
echo param2 - rom size in 18b words
echo param3 - bitfile.bit

if exist .\%1.mem (
	if [%2] GTR [0] (
		goto xtcl
	) else (
		echo ERROR:2 - Check ROM size
		goto end
	) 
) else (
  echo ERROR:1 - Unable to find mem file
  goto end
)

:xtcl
xtclsh 2xmem.tcl %1 %2
if exist .\%1.x.mem (
	if exist .\%3.bit (
		goto data2mem
	) else (
		echo ERROR:3 - Unable to find BIT file - Check top level name
		del .\%1.x.mem
		goto end
	) 
) else (
  echo ERROR:4 - Unable to create xmem file - Check design name or ROM size
  goto end
)
  
:data2mem
data2mem -bm pico6a7.bmm -bd %1.x.mem -bt %3.bit -o b program.bit
del .\%1.x.mem

if exist .\program.bit goto impact
  echo ERROR:5 - Unable to create BIT file - Check memory map 
  goto end

:impact
@echo setMode -bscan                                > impact_batch.cmd
@echo setCable -p auto                              >> impact_batch.cmd
@echo addDevice -position 1 -file .\program.bit     >> impact_batch.cmd
@echo ReadIdcode -p 1                               >> impact_batch.cmd
@echo program -p 1                                  >> impact_batch.cmd
@echo quit                                          >> impact_batch.cmd
impact -batch impact_batch.cmd
del .\impact_batch.cmd
del .\program.bit

:end
rem pause

@echo off

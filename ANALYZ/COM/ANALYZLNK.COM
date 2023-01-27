$!
$!	[ A N A L Y Z . C O M ] A N A L Y Z L N K . C O M
$!
$
$! Link ANALYZOBJ for the ANALYZE/OBJECT and ANALYZE/IMAGE commands.
$
$	delete exe$:analyzobj.exe;*, map$:analyzobj.map;*
$	link/notraceback -
	    /executable=exe$:analyzobj -
	    /map=map$:analyzobj/full/cross_reference -
			lib$:analyzobj/library/include=objexe, -
			sys$input:/options
psect=$plit$,exe
$
$! Link ANALYZRMS for the ANALYZE/RMS_FILE command.
$
$	delete exe$:analyzrms.exe;*, map$:analyzrms.map;*
$	link/notraceback -
	    /executable=exe$:analyzrms -
	    /map=map$:analyzrms/full/cross_reference -
			lib$:analyzrms/library/include=rms, -
			sys$input:/options
psect=$plit$,exe

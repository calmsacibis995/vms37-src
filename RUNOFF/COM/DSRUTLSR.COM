!
!	[ R U N O F F . C O M ] D S R U T L S R . D A T
!
!	This command file will either SAVE or RESTORE the object files
!	specific to DSR's utilities.
!
!	The passed parameter must be either SAVE or RESTORE.
!
$ goto 'p1
$ exit 4
!
$SAVE:
!
!	This section saves the object files by renaming them to .OBS
!
!$ RENAME	OBJ$:NDXDMP.OBJ	OBJ$:NDXDMP.OBS
$ RENAME	OBJ$:TCX.OBJ	OBJ$:TCX.OBS
$ RENAME	OBJ$:TCXFLO.OBJ	OBJ$:TCXFLO.OBS
$ RENAME	OBJ$:TOC.OBJ	OBJ$:TOC.OBS
$ RENAME	OBJ$:XPASSA.OBJ	OBJ$:XPASSA.OBS
$ RENAME	OBJ$:XPASSB.OBJ	OBJ$:XPASSB.OBS
$ EXIT 1
!
$RESTORE:
!
!	This section restores the saved object files by renaming them
!	back to .OBJs
!
!$ RENAME	OBJ$:NDXDMP.OBS	OBJ$:NDXDMP.OBJ
$ RENAME	OBJ$:TCX.OBS	OBJ$:TCX.OBJ
$ RENAME	OBJ$:TCXFLO.OBS	OBJ$:TCXFLO.OBJ
$ RENAME	OBJ$:TOC.OBS	OBJ$:TOC.OBJ
$ RENAME	OBJ$:XPASSA.OBS	OBJ$:XPASSA.OBJ
$ RENAME	OBJ$:XPASSB.OBS	OBJ$:XPASSB.OBJ
$ EXIT 1

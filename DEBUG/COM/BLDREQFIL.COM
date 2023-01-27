$ ! **************************** BLDREQFIL.COM *********************************
$ !
$ !
$ ! This command file builds REQUIRE files used by the language-specific
$ ! Debugger modules from the central REQUIRE files DBGLIB and DBGPROLOG.
$ ! This is more fully explained in the comments for BLDREQFIL.FOR.
$ !
$ RUN COM$:BLDREQFIL
$ PURGE SRC$:DBGCOMPLG.REQ
$ BLISS/LIBRARY=SRC$:DBGCOMLIB.L32/LIST=LIS$:DBGCOMLIB.LIS  SRC$:DBGCOMLIB.REQ
$ PURGE SRC$:DBGCOMLIB.REQ
$ PURGE SRC$:DBGCOMLIB.L32
$ WRITE SYS$OUTPUT "--SRC$:DBGCOMLIB.L32 successfully built"
$ RUN COM$:BLDDSTREC
$ LIBRARY/MACRO/CREATE SRC$:DBGCOMLIB.MLB LIB$:DBGMSG.MAR, -
			SRC$:DBGCOMLIB.MAR,SRC$:DSTRECRDS.MAR
$ PURGE SRC$:DBGCOMLIB.MAR
$ PURGE SRC$:DSTRECRDS.MAR
$ PURGE SRC$:DBGCOMLIB.MLB
$ WRITE SYS$OUTPUT "--SRC$:DBGCOMLIB.MLB successfully built"

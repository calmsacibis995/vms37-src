$ !
$ ! [ F D L . C O M ] F D L S H R L N K . C O M
$ !
$ !	Link the shareable image of FDL facility procedures
$ !
$ DELETE EXE$:FDLSHR.EXE;*,MAP$:FDLSHR.MAP;*
$ LINK-
	/SHARE=EXE$:FDLSHR-
	/MAP=MAP$:FDLSHR-
	/NOTRACE-
	/FULL-
	/CROSS-
	 SYS$INPUT:/OPTIONS

!
! Options for fdlshrlnk.com
!
LIB$:FDL/INCLUDE=FDLCALL/LIBRARY
!
! Put the transfer vector in its own cluster
!
CLUSTER=TRANSFER_VECTOR,,,LIB$:FDL/INCLUDE=FDLTRFVEC
PSECT=_FDL$PLIT,EXE
COLLECT=TRANSFER_VECTOR,_FDL$CODE,_LIB$KEY0$,_LIB$KEY1$,_LIB$STATE$,_FDL$PLIT
!
! Set Global Section match control
!
GSMATCH=LEQUAL,1,0
!
! Define Universal symbols
!
UNIVERSAL= -
		FDL$AL_BLOCK,-
		FDL$_FACILITY,-
		FDL$_FAO_MAX,-
		FDL$_ABKW,-
		FDL$_ABPRIKW,-
		FDL$_BADLOGIC,-
		FDL$_CREATE,-
		FDL$_CREATED,-
		FDL$_CREATEDSTM,-
		FDL$_FDLERROR,-
		FDL$_ILL_ARG,-
		FDL$_INSVIRMEM,-
		FDL$_INVDATIM,-
		FDL$_MULPRI,-
		FDL$_MULSEC,-
		FDL$_NOQUAL,-
		FDL$_NULLPRI,-
		FDL$_OPENFDL,-
		FDL$_OPENIN,-
		FDL$_OUTORDER,-
		FDL$_READERR,-
		FDL$_RFLOC,-
		FDL$_SYNTAX,-
		FDL$_TITLE,-
		FDL$_UNPRIKW,-
		FDL$_UNQUAKW,-
		FDL$_UNSECKW,-
		FDL$_VALPRI,-
		FDL$_WARNING

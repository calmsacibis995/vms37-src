$ !
$ !	[ S U M . C O M ] S U M S H R L N K . C O M
$ !
$ !	Command file to produce the shareable image of the
$ !	Source Update Merge procedures.
$ !
$ DELETE EXE$:SUMSHR.EXE;*, MAP$:SUMSHR.MAP;*
$ LINK/NOSYSSHR/SHARE=EXE$:SUMSHR/MAP=MAP$:SUMSHR/FULL/CROSS -
	SYS$INPUT/OPTIONS
!
OBJ$:SUM/INCLUDE:(SUM$DATA,SUM$LIST,SUM$OPEN,SUM$EDIT,SUM$ERROR)
!
!	Create a separate cluster at low addressed end for the
!	transfer vectors.
!
CLUSTER=TRANSFER_VECTOR,,,OBJ$:SUM/INCLUDE=SUM$TFRVEC
!
!	Set match control and major id = 1, and minor = 1000
!
GSMATCH=LEQUAL,1,1000
!
!	Reduce number of image sections by combining PSECTS
!
PSECT=_LIB$STATE$,NOPIC,NOSHR
PSECT=_LIB$CODE,NOPIC,NOSHR
PSECT=_LIB$KEY0$,NOPIC,NOSHR
PSECT=_LIB$KEY1$,NOPIC,NOSHR
PSECT=_LIB$DATA,NOPIC
PSECT=SUM$RO_DATA,EXE

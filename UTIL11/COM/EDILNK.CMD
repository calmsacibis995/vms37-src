;
;	VAX/VMS EDI Build File
;
;	Modified for VAX/VMS by Ward Clark  03-FEB-78
;	Modified by R. Newland on 24-July-1979 to get INIDM routine
;	from VMLIB
;
EXE$:EDI.EXE/MM/CP/-FP,MAP$:EDI/MA/-SP=LIB$:EDI/LB:EDIMP:START
	SYS$LIBRARY:VMLIB/LB:INIDM,LIB$:EDI/LB
/
STACK=64
UNITS=6
ASG=CL:1,TI:2,SY:3:4:5:6
TASK=...EDI
PAR=GEN:0:140000
PRI=65
;
; add patch to make force upper case defaulted OFF
;
;GBLPAT=EDIMP:STRTS+70:105067
/

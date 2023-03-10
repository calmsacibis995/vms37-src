;
; TKB BUILD FILE FOR PIP
;
EXE$:PIP/FU/-FP/CP/MM,MAP$:PIP/-SP=
COM$:PIPLNK/MP
TASK=...PIP
STACK=64
UNITS=6
ASG=TI:1:2,LB:5
PAR=GEN:0:0
; PIP CAN ONLY MANAGE UP TO 16KW OF BUFFERS
EXTTSK=16384
PRI=50
TSKV=SSTTAB:7
;
; TO MAKE PRESERVATION OF CREATION DATE THE DEFAULT, UNCOMMENT THE NEXT LINE
;GBLPAT=PIP:$DEFSW:1
;
; PATCH THE LUN USED BY GERRM
;
GBLPAT=ERROR:.EOLUN:5
;
; PUT THE LINE PRINTER WIDTH (OCTAL) AFTER LPTLEN: IN THE FOLLOWING COMMAND
; 120 OCTAL FOR 80 COLUMN PRINTER, 204 OCTAL FOR 132 COLUMN PRINTER
;
GBLPAT=PIP:LPTLEN:204
;
; WHEN COPYING FILES TO THE LINE PRINTER, PIP WILL ISSUE A FORM
; FEED BEFORE COPYING THE FILE. IF THIS IS UNDESIRABLE, REMOVE
; THE COMMENT FROM THE NEXT GBLPAT
;
;GBLPAT=PIPCPY:.LPCHK+10:410
;
; MODULE RWLONG IS NOT USED SO DO NOT INCLUDE IT
;
GBLDEF=..RWLG:0
/

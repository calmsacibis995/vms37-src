!	THIS COMMAND PROCEDURE EXTRACTS A SINGLE FACILITY MESSAGE
!	FILE FROM THE SYSTEM-WIDE FACILITY MESSAGE FILE - 
!		SRCD$:[SYSMSG]SYSMSG.TLB
!
!	P1 = NAME OF MESSAGE FILE TO EXTRACT
!	
!	P2 = NAME OF FILE TO RECEIVE EXTRACTED TEXT
!	     [ DEFAULT IS SRC$:MSGFILENAM ]
!
$  IF P2 .EQS. "" THEN P2 := "SRC$:"'P1'
$  LIB/TEXT/EXTRACT=('P1')/OUT='P2'.MSG SRCD$:[SYSMSG]SYSMSG

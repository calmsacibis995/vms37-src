!	DBBx BOOT COMMAND FILE - DBBBOO.CMD
!	BOOT FROM DBBx
!
!	THE UNIT NUMBER IS SPECIFIED BY DEPOSITING THE DESIRED VALUE
!	IN R3 BEFORE INVOKING THIS COMMAND FILE.
!
D/G 0 0			! DISK PACK DEVICE TYPE
D/G 1 F2A000		! BASE OF MBA1 ADDRESS SPACE
D/G 2 1			! ADAPTER UNIT  = 1
D/G 4 0			! BOOT BLOCK LBN (UNUSED)
D/G 5 0			! SOFTWARE BOOT FLAGS
D/G E 200		! ADDRESS OF WORKING MEMORY + ^X200
LOAD VMB.EXE/START:200	! LOAD PRIMARY BOOTSTRAP
START 200		! START PRIMARY BOOTSTRAP

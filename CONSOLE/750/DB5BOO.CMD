!
!	DB5 BOOT COMMAND FILE - DB5BOO.CMD
!
D/G 0 0			! DISK PACK DEVICE TYPE
D/G 1 F28000		! BASE OF MBA0 ADDRESS SPACE
D/G 2 0			! ADAPTER UNIT = 0
D/G 3 5			! CONTROLLER UNIT = 5
D/G 4 0			! BOOT BLOCK LBN	(UNUSED)
D/G 5 0			! SOFTWARE BOOT FLAGS
D/G E 200		! ADDRESS OF WORKING MEMORY + ^X200
LOAD VMB.EXE/START:200	! LOAD PRIMARY BOOTSTRAP
START 200		! START PRIMARY BOOTSTRAP

!	[ T R A C E . C O M ]  T R A C E U P D . C O M
!
!	This file is used to apply the updates to the master copy of the
!	require files during the system build procedure, UPDATE phase.
!
$ DELETE SRC$:*.*;*
$ SRCUPDATE TRACEMSG.MDL
$ SRCUPDATE TBKGEN.REQ
$ SRCUPDATE TBKPCT.REQ
$ SRCUPDATE TBKRST.REQ
$ SRCUPDATE TBKSER.REQ

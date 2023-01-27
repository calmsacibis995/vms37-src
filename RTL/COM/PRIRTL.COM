$ ! Print entire VAX Run Time Library
$ ! Edit history:
$ !
$ ! 1-001 - Added fifth binder and removed P.MAR  JBS 27-NOV-78
$ ! 1-002 - Binders reorganized.  SBL 30-NOV-78
$ ! 1-003 - Add sixth binder and include COM$:.  JBS 22-DEC-78
$ ! 1-004 - Bring comments up to date.  JBS 05-AUG-1979
$ ! 1-005 - Add the seventh and eighth binders.  JBS 05-AUG-1979
$ !
$ ! First binder:
$ !	Table of Contents
$ !	Copyright text
$ !	All Command files
$ !	All Require files
$ !	All internal documentation
$ !	Cross reference of BLISS modules
$ !	Map of VMSRTL.EXE
$ !
$ @COM$:PRIFIRBIN
$ !
$ ! Second binder:
$ !	FORTRAN Compatibility Library
$ !	FORTRAN Language Support Library
$ !
$ @COM$:PRISECBIN
$ !
$ ! Third binder:
$ !	General Utility Library
$ !
$ @COM$:PRITHIBIN
$ !
$ ! Fourth binder:
$ !	    All Math library
$ !
$ @COM$:PRIFOUBIN
$ !
$ ! Fifth binder:
!	All OTS modules
$ !
$ @COM$:PRIFIFBIN
$ !
$ ! Sixth binder:
$ !	All of the BASIC-PLUS-2 code.
$ !
$ @COM$:PRISIXBIN
$ !
$ ! Seventh binder:
$ !	All STR (string) modules.
$ !
$ @COM$:PRISEVBIN
$ !
$ ! Eighth binder:
$ !	ALL COB (COBOL-79) modules.
$ !
$ @COM$:PRIEIGBIN
$ !
$ !	[End of PRIRTL.COM]

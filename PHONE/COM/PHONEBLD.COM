$ !
$ !	[ P H O N E . C O M ] P H O N E B L D . C O M
$ !
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT

$UPDATE:
$ !
$ !	Update the require file and internal help file.
$ !
$ SRCUPDATE PHONEREQ.REQ
$ SRCUPDATE PHONEHELP.HLP
$ EXIT
$
$SRCLIB:
$ !
$ !	Build the internal help library.
$ !
$ LIBRARY/CREATE=(BLOCKS=40,MODULES=30)/HELP OBJ$:PHONEHELP.HLB SRC$:PHONEHELP.HLP
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and recreate the object files and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM PHONE "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library
$ !
$ @SYSBLDCOM$:OBJLIB PHONE
$ EXIT
$
$LNKLIB:
$ !
$ !	Null LNKLIB phase
$ !
$ EXIT
$
$LINK:
$ !
$ !	Delete images and maps and then recreate
$ !
$ @COM$:PHONELNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the images and maps to the system area
$ !
$ CPYRESEXE EXE$:PHONE.EXE
$ CPYRESMAP COM$:PHONELNK.COM,MAP$:PHONE.MAP PHONE.MAP
$ COPY MSRC$:PHONECOM.COM RESEXE$:PHONE.COM
$ CPYSYSHLP OBJ$:PHONEHELP.HLB
$ !
$ !	Build the concatenated listings
$ !
$ CPYRESLIS SRC$:*.REQ,SRC$:*.MSG,LIS$:*.LIS PHONE.LSS

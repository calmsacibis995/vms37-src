$ !
$ !	[ E D T . C O M ] E D T B L D . C O M
$ !
$ !	Assume default directory is [EDT] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$
$ !	are defined.
$ !
$ GOTO 'PHASE'
$ 
$INIT:
$ !
$ !	Create the Directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ SRCUPDATE EDT.REQ
$ SRCUPDATE PARSTA.REQ
$ SRCUPDATE EDTHELP.HLP
$ SRCUPDATE EDTVT100.DOC
$ SRCUPDATE EDTVT52.DOC
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the Bliss library EDT.L32
$ !
$ BLISS /LIBRARY=LIB$:EDT SRC$:EDT.REQ
$ LIBRARY /HELP /CREATE=(MODULES:25) LIB$:EDTHELP SRC$:EDTHELP
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @COM$:EDTASNREQ
$ @SYSBLDCOM$:FASM EDT "" N 'UPDATES'
$ @COM$:EDTDEAREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB EDT 200 500 50
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ EXIT
$
$LINK:
$ !
$ !	Delete EDT map and image then re-create EXE$:EDT.EXE
$ !			and MAP$:EDT.MAP
$ !
$ DELETE EXE$:EDT.EXE;*,	MAP$:EDT.MAP;*
$ @COM$:EDTLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:EDT.EXE
$ CPYRESMAP COM$:EDTLNK.COM,MAP$:EDT.MAP	LIBRARIAN.MAP
$ CPYSYSHLP LIB$:EDTHELP.HLB
$ CPYSYSHLP SRC$:EDTVT100.DOC
$ CPYSYSHLP SRC$:EDTVT52.DOC
$ !
$ !	Build the concatenated listing LIBRAR.LSS
$ !
$ CPYRESLIS LIS$:*.LIS EDT.LSS

$ !
$ !	Create an object library from .OBJ files with the name 'P1'.
$ !
$ !	P1 - Facility name
$ !	P2 - no. of blocks
$ !	P3 - no. of globals
$ !	P4 - no. of modules
$ !
$ BLOX:='P2'
$ GLOBS:='P3'
$ MODS:='P4'
$ IF BLOX .EQS. "" THEN BLOX:=100
$ IF GLOBS .EQS. "" THEN GLOBS:=275
$ IF MODS .EQS. "" THEN MODS:=75
$ ON ERROR THEN EXIT
$ LIB/CREATE=(BLOCKS='BLOX,GLOBALS='GLOBS,MODULES='MODS) LIB$:'P1' OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ PURGE LIB$:'P1'.OLB
$ IF CPYOLB THEN CPYRESOBJ LIB$:'P1'.OLB

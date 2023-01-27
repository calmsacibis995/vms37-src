$ !
$ ! Command file to build 11M Utilities
$ !
$ ! This procedure assumes the following:
$ !	DEFAULT = [UTIL11]
$ !	logical names SRC$:, LIB$:, MAP$:, EXE$: and OBJ$: are defined
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ ! Create UTIL11 directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated require file sources.  (NONE)
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	No macro library.
$ !
$ EXIT
$
$ASSEM:
$ !
$ ! Assemble the modified and new PIP utility modules
$ ! Assemble the HEXZAP modules
$ !
$ DELETE  OBJ$:*.OBJ;*, LIS$:*.LST;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ ! Create the necessary 11M utility object libraries
$ !
$ DELETE  LIB$:*.OLB;*
$ COPY  PRMOBJ$:*.OLB  LIB$:
$ !
$ ! Create the HEXZAP object library
$ !
$ MCR LBR LIB$:HEXZAP/CR=OBJ$:ZAP,ZBLILB,ZCLOSE,ZIN11M,ZIOSRV,ZLSTIO,ZOPEN,ZPROC
$ !
$ ! COPY PIPUTL AND TKB OLB'S TO RESOBJ FOR OTHERS TO USE
$ !
$ CPYRESOBJ LIB$:PIPUTL.OLB
$ CPYRESOBJ LIB$:TKB.OLB
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
$ ! Link each 11M utility
$ !	The TKBLPG command procedure links the utility twice with
$ !	different "lines-per-page" parameters and automatically
$ !	generates the difference data for LINEPAGE.COM to use.
$ !
$ DELETE  EXE$:*.EXE;*, *LPG.DAT;*, MAP$:*.MAP;*
$ SET NOON
$ MCR TKB @COM$:BADLNK
$ @SYSBLDCOM$:TKBLPG CRF CRFLNK "L$NMAX"	! Link CRF
$ MCR TKB @COM$:EDILNK
$ MCR TKB @COM$:FLXLNK
$ MCR TKB @COM$:HEXZAPLNK
$ MCR TKB @COM$:LBRLNK
$ @SYSBLDCOM$:TKBLPG MAC MACLNK LINPPG		! Link MAC
$ MCR TKB @COM$:PATLNK
$ MCR TKB @COM$:PIPLNK
$ @SYSBLDCOM$:TKBLPG SLP SLPLNK "P$GLGH"	! Link SLP
$ @SYSBLDCOM$:TKBLPG TKB TKBLNK "P$LNTH"
$ MCR TKB @COM$:ZAPLNK
$ EXIT
$
$RESULT:
$ !
$ ! Copy the 11M utility images and listing files into system areas
$ !
$ CPYRESEXE EXE$:*.EXE
$ CPYRESEXE EXE$:MACLPG.DAT,CRFLPG.DAT,SLPLPG.DAT,TKBLPG.DAT
$ CPYRESMAP MAP$:*.MAP
$ CPYRESLIS LIS$:*.LST UTIL11UPD.LSS

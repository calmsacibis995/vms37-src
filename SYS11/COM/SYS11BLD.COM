$ !
$ ! Command file to build SYSLIB and related components
$ !
$ ! This procedure assumes the following:
$ !	DEFAULT = [SYS11]
$ !	logical names SRC$:, LIB$:, MAP$:, EXE$: and OBJ$: are defined
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ ! Create the necessary SYS11 directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ @COM$:SYS11UPD
$ !
$ ! Copy the modified 11M components into the LIBD$:[SYSLIB] and
$ ! LIBD$:[SYSMSG] areas, which are assumed to be there
$ !
$ !
$ CPYRES SYS$LIBRARY: PRMOBJ$:SYSLIB.OLB
$ CPYRES SYS$LIBRARY: PRMOBJ$:VMLIB.OLB
$ CPYRES SYS$LIBRARY: PRMOBJ$:TRACE.OBJ
$ CPYRES SYS$LIBRARY: PRMOBJ$:ODT.OBJ
$ CPYRES SYS$LIBRARY: PRMOBJ$:RSXMAC.SML
$ CPYRES SYS$LIBRARY: PRMOBJ$:NEISLB.OLB
$ CPYRES SYS$LIBRARY: PRMOBJ$:EXEMC.MLB
$ CPYSYSMSG PRMOBJ$:QIOSYM.MSG
$ !
$ ! Add ODS-2 macros (file header offset definitions) to RSXMAC.SML
$ ! Replace FCS-11 macros with VMS-specific versions
$ !
$ COPY MSRC$:FCSMACVAX.MAC SRC$
$ LIBRARY/RSX/MAC SYS$LIBRARY:RSXMAC.SML SRC$:OD2MAC.MAC,SRC$:FCSMACVAX.MAC
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
$ ! No ASSEM phase
$ !
$ EXIT
$
$OBJLIB:
$ !
$ ! Null objlib phase
$ !
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
$ !	No link phase.
$ !
$ EXIT
$
$RESULT:
$ !
$ ! Null result phase
$ !
$ EXIT

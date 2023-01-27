$ !
$ !	[ M O U N T . C O M ] M O U N T B L D . C O M
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
$ !	Create updated require file sources
$ !
$ DELSHRLIB SRC$:MOUDEF.B32
$ DELETE SRC$:*.*;*
$ SRCUPDATE MOUDEF.B32
$ CPYSHRLIB SRC$:MOUDEF.B32
$ EXIT
$
$SRCLIB:
$ PREVDIR:='F$LOG("SYS$DISK")''F$DIR()'
$ SET DEF [VMSLIB]
$ MESSAGE/MDL=SRC$:MOUNTMSG/NOOBJ SRC$:MOUNTMSG
$ MCR MDL LIB$:MOUNTMSG=SRC$:MOUNTMSG
$ COPY LIB$:MOUNTMSG.B32 LIB$:MOUNTMSG.REQ
$ SET DEF 'PREVDIR'
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the objects and listings
$ !
$ REMSHRLIB FCPDEF.B32
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ GETSHRLIB FCPDEF.B32
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB VMOUNT
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete shareable mount map and image and then re-create it.
$ !
$ DELETE EXE$:MOUNTSHR.EXE;*,  MAP$:MOUNTSHR.MAP;*
$ @COM$:MNTSHRLNK		! Link the shareable image
$ CPYSYSLIB EXE$:MOUNTSHR.EXE	! Copy to library area
$ INSHARLIB EXE$:MOUNTSHR	! Insert into IMAGELIB.OLB
$ EXIT
$
$LINK:
$ !
$ !	Delete MOUNT map and image then re-create EXE$:VMOUNT.EXE
$ !			and MAP$:VMOUNT.MAP
$ !
$ DELETE EXE$:VMOUNT.EXE;*, MAP$:.MAP;*
$ @COM$:MOUNTLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:VMOUNT.EXE
$ CPYRESMAP MAP$:VMOUNT.MAP
$ !
$ !	Build the concatenated listing RESLIS$:VMOUNT.LSS
$ !
$ CPYRESLIS SRC$:MOUDEF.B32,LIS$:*.LIS VMOUNT.LSS

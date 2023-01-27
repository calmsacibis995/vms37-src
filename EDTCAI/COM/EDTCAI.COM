$ !
$ !	Installation kit for the EDT CAI course
$ !
$ ! This .COM file assumes the following:
$ !
$ !	P1 is the name of the device where the save-set EDTCAI1 is mounted.
$ !	EDTCAI1 contains all of the software and library files to be placed
$ !		onto this system, in a form where they will be automatically
$ !		placed into the correct directories (SYS$SYSTEM and SYS$INSTRUCTION).
$ !		These files are:	SYS$SYSTEM:EDTCAI.EXE
$ !					SYS$SYSTEM:ADMIN.EXE
$ !					SYS$SYSTEM:EDTCAICNV.EXE
$ !					SYS$INSTRUCTION:CBICOURSE.DAT
$ !					SYS$INSTRUCTION:EDTCAI.DIC
$ !					SYS$INSTRUCTION:EDTEXER4.COM
$ !					SYS$INSTRUCTION:EDTEXER4.DAT
$ !					SYS$INSTRUCTION:EDTEXER5.COM
$ !					SYS$INSTRUCTION:EDTEXER5.DAT
$ !					SYS$INSTRUCTION:EDTV52.DLB
$ !					SYS$INSTRUCTION:EDTVT1.DLB
$ !
$ TYPE SYS$INPUT

This procedure will install the EDTCAI course on your system.

Now deleting old versions of the course.  Please ignore possible
File-not-found messages.

$ DELETE SYS$SYSTEM:EDTCAI.EXE;*,SYS$SYSTEM:ADMIN.EXE;*
$ DELETE SYS$SYSTEM:EDTCAICNV.EXE;*
$ DELETE SYS$INSTRUCTION:EDTV52.DLB;*,SYS$INSTRUCTION:EDTVT1.DLB;*
$ DELETE SYS$INSTRUCTION:CBICOURSE.DAT;*,SYS$INSTRUCTION:EDTCAI.DIC;*
$ DELETE SYS$INSTRUCTION:EDTEXER4.COM;*,SYS$INSTRUCTION:EDTEXER4.DAT;*
$ DELETE SYS$INSTRUCTION:EDTEXER5.COM;*,SYS$INSTRUCTION:EDTEXER5.DAT;*
$ !
$ TYPE SYS$INPUT

This course will work on either a VT52 or VT100 compatible
terminal.  However, the display library for each terminal type
is over 500 blocks, and if you do not have a particular terminal
type on your system, you might wish to save disk space by not
installing that particular library.

$ !
$ BEGIN:
$ !
$ NO_VT52 := ""
$ INQUIRE READY "Do you wish to install the display library for VT52 terminals?"
$ IF .NOT. READY THEN $ NO_VT52 := "/EXCLUDE=(EDTV52.DLB)"
$ !
$ NO_VT100 := ""
$ INQUIRE READY "Do you wish to install the display library for VT100 terminals?"
$ IF .NOT. READY THEN $ NO_VT100 := "/EXCLUDE=(EDTVT1.DLB)"
$ !
$ IF NO_VT52 .EQS. "" .OR NO_VT100 .EQS. "" THEN $ GOTO RESTORE
$ !
$ ! Here the person requested neither of the libraries be installed.  This means
$ ! the course will not run at all.  Inform them of this fact, and try again.
$ !
$ TYPE SYS$INPUT

You must install at least one of the two library files for the
EDTCAI course to run on your system.

$ GOTO BEGIN
$ !
$ RESTORE:
$ BACKUP	'P1'[0,0]EDTCAI1.SAV -
		'NO_VT52' -
		'NO_VT100' -
		/SAVE_SET -
		/REPLACE -
		SYS$SYSDEVICE:[*...]
$ !
$ RUN SYS$SYSTEM:ADMIN
ADD COURSE SYS$INSTRUCTION:CBICOURSE.DAT
$ !
$ CREATE SYS$INSTRUCTION:COMMENT.DAT
$ !
$ SET PROTECTION=W:RE SYS$INSTRUCTION:EDTCAI.DIC,EDTEXER%.*,EDT*.DLB
$ SET PROTECTION=W:RW SYS$INSTRUCTION:ROSTER.DAT,SYS$INSTRUCTION:COMMENT.DAT
$ !
$ ! If they previously installed EDTCAI V1.0, then check to see whether
$ ! they want to copy over all the records of the students work to this
$ ! version of EDTCAI.
$ !
$ IF F$LOGICAL("EDT$CAI") .EQS. "" THEN ASSIGN 'F$LOGICAL("SYS$LIBRARY") EDT$CAI
$ !
$ IF F$SEARCH("EDT$CAI:CONTROL.DAT") .EQS. "" THEN GOTO FINISH
$ !
$ WRITE SYS$OUTPUT ""
$ INQUIRE READY "Do you wish to copy student records from EDTCAI V1 to this version?"
$ IF .NOT. READY THEN GOTO FINISH
$ !
$ RUN SYS$SYSTEM:EDTCAICNV
$ !
$ TYPE SYS$INPUT

Now that the student records are copied, you may delete the old
records to save disk space.

$ INQUIRE READY "Do you wish to delete the old student records (Y or N)"
$ IF .NOT. READY THEN GOTO NO_DELETE
$ !
$ OPEN/READ/ERROR=NO_DELETE FILE EDT$CAI:CONTROL.DAT
$ READ/ERROR=NO_DELETE FILE LINE1
$ READ/ERROR=NO_DELETE FILE LINE2
$ READ/ERROR=NO_DELETE FILE ROSTER_DIRECTORY
$ CLOSE FILE
$ !
$ SET PROTECTION=S:D EDT$CAI:CONTROL.DAT;*
$ DELETE EDT$CAI:CONTROL.DAT;*
$ SET PROTECTION=S:D 'ROSTER_DIRECTORY'ROSTER.DAT;*
$ DELETE 'ROSTER_DIRECTORY'ROSTER.DAT;*
$ GOTO FINISH
$ !
$ NO_DELETE:
$ TYPE SYS$INPUT

The old student records have not been deleted.

$ !
$ FINISH:
$ TYPE SYS$INPUT

EDTCAI Installation Complete.

$ EXIT

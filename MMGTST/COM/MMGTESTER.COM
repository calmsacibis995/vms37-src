$ !	THIS COMMAND FILE EXERCISES THE MEMORY MANAGEMENT PROGRAMS.
$ !     ***********************************************************
$ !
$ !   In order to run this driver you must have in your possesion
$ ! the SETPRV privelege.  This is necessary as the privileges 
$ ! needed to run the MMG test programs vary and to prevent any
$ ! bottlenecks if further tests are to be added at a later date.
$ !   Before running this program it is necessary to have copied
$ ! all of the testing programs and assorted tag alongs to a disk
$ ! and file of your choosing.  If you have not done this as of yet
$ ! the file you are looking for is located on MASD$:[MMGTST.COM].
$ ! The specific file is MMGCOPY.COM.  When you invoke this procedure
$ ! you will be prompted for the SOURCE disk, a TARGET disk, and a 
$ ! TARGET directory.  It will then copy all the necessary code to
$ ! that area, including this driver.  At that point all you must do
$ ! is say @MMGTESTER and you are off.  You will be prompted for the
$ ! tests you would like executed and asked for several parameters.
$ ! These are as follows:
$ !
$ !	1. Do you have shared memory?
$ !	2. If so, do you wish to invoke it?
$ !	3. Do you wish to do all tests.  If not, which would 
$ !	  you like run.
$ !
$ !   Refer to MASD$:[MMGTST.COM]MMGTST.RAP for further information
$ ! regarding the following:
$ !
$ !	1. Which of the system services is tested.
$ !	2. What MMG test program is responsible for testing the service.
$ !	3. How completely the system service is tested.
$ !
$ !
$ ! IMPORTANT NOTE:
$ ! ***************
$ !	Your default directory must be set to the TARGET device and
$ !	TARGET directory you specified when you invoked MMGCOPY.
$ !	The reason for this is that in the course of running these
$ !	tests it is necessary to ramble into other areas of the
$ !	system, so the default directory is stored immediately upon
$ !	invoking  MMGTESTER in order that the home point be
$ !	established for later reference (when command procedure
$ !	must find its way home to run next test).  THEREFORE, make
$ !	SURE your DEFAULT DIRECTORY is set to the TARGET device and
$ !	TARGET directory YOU specified when you ran the MMGCOPY command
$ !	procedure.
$ !
$ ERASE
$ !
$ !INITIALIZATION OF POSSIBLE TEST NUMBERS AND
$ ! FILE FOR $CRMPSC SYSTEM SERVICE.
$ !
$ TEMP:=X
$ MMGTEST1:=X
$ MMGTEST2:=X
$ MMGTEST3:=X
$ MMGTEST4:=X
$ MMGTEST5:=X
$ MMGTEST6:=X
$ MMGTEST7:=X
$ MMGTEST8:=X
$ RUN MMGCRTFIL			!CREATE FILE FOR $CRMPSC SYSTEM SERV.
$ !
$ !	FIND AND STORE CURRENT DEFAULT DIRECTORY
$ !
$ DIR/OUTPUT=MMGTMP.TMP/TOTAL
$ OPEN/READ X MMGTMP.TMP
$ READ X Y
$ READ X Y
$ DEFDIR := 'F$EXTRACT(10,99,Y)
$ CLOSE X
$ DELETE MMGTMP.TMP;*
$ SET PROC/PRIV=SYSNAM
$ DEFINE /SYSTEM MMGACCOUNT 'DEFDIR
$ !
$ !	???????? SHARED MEMORY CAPABILITY ????????
$ !
$ INQUIRE SHRMEM "Do you have SHARED MEMORY capability?"
$ SHRYES := NO
$ IF SHRMEM THEN INQUIRE SHRYES "Do you wish to do tests also with SHARED MEMORY?"
$ DEFINE/SYSTEM MMGSHRMEM 'SHRYES
$ SET PROC/PRIV=NOSYSNAM
$ IF "''F$LOGICAL("MMGSHRMEM")'" .NES. "YES" THEN GOTO CONTINUE
$ SET PROC/PRIV=SHMEM
$ RUN SYS$SYSTEM:SYSGEN
  SHARE MPM0 SHM /INIT /GBL=10
$ SET PROC/PRIV=NOSHMEM
$ WRITE SYS$OUTPUT "SHARED MEMORY has been invoked."
$
$CONTINUE:
$ INQUIRE ALLTSTS "Do you wish to do ALL tests?"
$ IF ALLTSTS THEN GOTO DO_ALL_TESTS
$
$MENU:
$ WRITE SYS$OUTPUT "Which test do you want run?"
$ INQUIRE WHICH_TESTS "(use test number, separate by commas, H for help)"
$ IF WHICH_TESTS .NES. "H" THEN GOTO SPLIT_APART
$ TYPE SYS$INPUT

	Possible tests are:

1	CRDLSP		- Test of $CRETVA/$DELTVA/$SETPRT system services.
2	SETPRT		- Test of $SETPRT system service.
3	CRTDEL		- Test of $CRETVA/$DELTVA system services.
4	ADJWSL		- Test of $ADJWSL system service.
5	EXPCNT		- Test of $EXPREG/$CNTREG system services.
6	LKWULW		- Test of $LKWULW/$ULWSET system services.
7	XQUOTA		- Test of MMG services with LOW PGFLQUOTA.
8	NSFWSL		- Test of MMG services with LOW WSQUOTA/WSLIMIT.


	SAMPLE INPUT:   1,4,7,8

$ GOTO MENU
$
$DO_ALL_TESTS:
$ WHICH_TESTS:=1,2,3,4,5,6,7,8
$ 
$SPLIT_APART:
$ ERASE
$ WHICH_TESTS:= 'WHICH_TESTS'','
$
$FIND_NEXT:
$ IF 'F$LENGTH(WHICH_TESTS) .LE. 1 THEN GOTO EXIT_ROUTINE
$ END = 'F$LOCATE(",",WHICH_TESTS)
$ TEST_NUMBER := 'F$EXTRACT(0,END,WHICH_TESTS)
$ END = END+1
$ WHICH_TESTS := 'F$EXTRACT(END,200,WHICH_TESTS)
$ DELETE/SYMBOL TEMP
$ TEMP[0,1]:="'"
$ TEMP[1,18]:="'MMGTEST"'TEST_NUMBER'"'"
$ TEMP:="''TEMP'"
$ IF TEMP .EQS. "" THEN GOTO ERROR_MESSAGE
$ GOTO MMGTEST'TEST_NUMBER
$
$ERROR_MESSAGE:
$ WRITE SYS$OUTPUT " "
$ WRITE SYS$OUTPUT "***  TEST #''TEST_NUMBER' DOES NOT EXIST.  REQUEST FOR TEST IGNORED. ***"
$ WRITE SYS$OUTPUT ""
$ GOTO FIND_NEXT
$
$EXIT_ROUTINE:
$ INQUIRE MORE "Do you wish to do any other tests?"
$ IF MORE THEN GOTO CONTINUE
$ EXIT
$
$MMGTEST1:
$ SET PROC/PRIV=(PRMGBL,PFNMAP)
$ RUN MMGCRDLSP
$ IF "''F$LOGICAL("MMGSHRMEM")'" .NES. "YES" THEN GOTO FIND_NEXT
$ DEFINE MMGTST SHM:MMGTST
$ TYPE SYS$INPUT

	*******************************************************
	***   TEST WILL NOW BE RUN WITH THE SHARED MEMORY   ***
	*******************************************************

$ RUN MMGCRDLSP
$ DEFINE MMGTST MMGTST
$ SET PROC/PRIV=(NOPRMGBL,NOPFNMAP)
$ GOTO FIND_NEXT
$
$MMGTEST2:
$ RUN MMGSETPRT
$ GOTO FIND_NEXT
$
$MMGTEST3:
$ RUN MMGCRTDEL
$ GOTO FIND_NEXT
$
$MMGTEST4:
$ RUN MMGADJWSL
$ GOTO FIND_NEXT
$
$MMGTEST5:
$ RUN MMGEXPCNT
$ GOTO FIND_NEXT
$
$MMGTEST6:
$ RUN MMGLKWULW
$ IF "''F$LOGICAL("MMGSHRMEM")'" .NES. "YES" THEN GOTO FIND_NEXT
$ DEFINE MMGTST SHM:MMGTST
$ TYPE SYS$INPUT

	*******************************************************
	***   TEST WILL NOW BE RUN WITH THE SHARED MEMORY   ***
	*******************************************************

$ RUN MMGLKWULW
$ GOTO FIND_NEXT
$
$MMGTEST7:
$ SET DEF SYS$SYSTEM
$ SET PROC/PRIV=SYSPRV
$ MCR AUTHORIZE
 ADD LUMMY/PASS=DUMMY
 MODIFY LUMMY/PGFLQUOTA=256
 MODIFY LUMMY/PRIV=SETPRV
 MODIFY LUMMY/PRIV=SYSPRV
 EXIT
$ SET HO SYS$NODE
LUMMY
DUMMY
SET DEFAULT 'F$LOGICAL("MMGACCOUNT")
SET PROC/PRIV=(PRMGBL,PFNMAP)
RUN MMGXQUOTA
LOG
$ IF "''F$LOGICAL("MMGSHRMEM")'" .NES. "YES" THEN GOTO BYPASS_1
$ SET HO SYS$NODE
LUMMY
DUMMY
SET DEFAULT 'F$LOGICAL("MMGACCOUNT")
SET PROC/PRIV=(PRMGBL,PFNMAP)
DEFINE MMGTST SHM:MMGTST
WRITE SYS$OUTPUT ""
WRITE SYS$OUTPUT "	*******************************************************"
WRITE SYS$OUTPUT "	***   TEST WILL NOW BE RUN WITH THE SHARED MEMORY   ***"
WRITE SYS$OUTPUT "	*******************************************************"
WRITE SYS$OUTPUT ""
RUN MMGXQUOTA
DEFINE MMGTST MMGTST
SET DEF SYS$SYSTEM
MCR AUTHORIZE
REMOVE LUMMY
EXIT
LOG
$ GOTO BYPASS_2

$ BYPASS_1:
$ SET DEF SYS$SYSTEM
$ MCR AUTHORIZE
 REMOVE LUMMY
 EXIT

$ BYPASS_2:
$ SET PROC/PRIV=NOSYSPRV
$ SET DEF 'F$LOGICAL("MMGACCOUNT")
$ GOTO FIND_NEXT
$
$MMGTEST8:
$ SET DEF SYS$SYSTEM
$ SET PROC/PRIV=SYSPRV
$ MCR AUTHORIZE
 ADD LUMMY/PASS=DUMMY
 MODIFY LUMMY/WSQUOTA=40
 MODIFY LUMMY/PRIV=SYSPRV
 EXIT
$ SET HO SYS$NODE
LUMMY
DUMMY
SET DEFAULT 'F$LOGICAL("MMGACCOUNT")
RUN MMGNSFWSL
SET DEF SYS$SYSTEM
MCR AUTHORIZE
REMOVE LUMMY
EXIT
LOG
$ SET PROC/PRIV=NOSYSPRV
$ SET DEFAULT 'F$LOGICAL("MMGACCOUNT")
$ GOTO FIND_NEXT

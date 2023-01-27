$ !	[SYSBLDCOM]RESULTCPY.COM
$ !
$ ! This command file copies the relevant result areas of the output of a
$ ! system build to the work disk for use in private development. The
$ ! contents of [SYSOBJ] are copied, along with the command files to
$ ! build those components that link with the exec.
$ !
$ !	P1 = device name of result disk to copy
$ !	P2 = device name of target disk
$ !
$10:
$ if p1 .nes. "" then goto 20
$ inquire p1 "What is the device name of the result disk? [ddcu:]"
$20:
$ if p2 .nes. "" then goto 30
$ inquire p2 "What is the device name of the target disk? [ddcu:]"
$ goto 20
$30:
$! reply /all "RESOBJ$ update starting..."
$ define sys$print nowhere
$ set noon
$ if 'f$locate(":",p1) .eq. 'f$length(p1) then p1:='p1':
$ !
$ !	Copy over the new [SYSOBJ]
$ !
$ set process/priv=bypass
$ delete 'P2'[sysobj]*.obj;*
$ delete 'P2'[sysobj]*.olb;*
$ delete 'P2'[sysobj]*.stb;*
$ delete 'P2'[sysobj]*.exe;*
$! delete 'P2'[syslib]starlet.olb;*
$! delete 'P2'[shrlib]*.*;*
$ set process/priv=nobypass
$ copy/prot=(owner:rwed) 'p1'[sysobj]*.* 'P2'[sysobj]
$ copy/prot=(owner:rwed) 'p1'[syslib]rsxshr.exe 'P2'[sysobj]
$! copy/prot=(owner:rwed) 'p1'[syslib]starlet.olb 'P2'[syslib]
$! copy/prot=(owner:rwed) 'p1'[shrlib]*.* 'P2'[shrlib]
$ !
$ !	Open the facility data file and find the components that link
$ !	with the exec. For each one, create the [component.COM] directory
$ !	if it doesn't already exist and copy in the command files.
$ !
$ open data sysbldcom$:vmsnewbld.dat  ! open facility data file
$ !
$ ! get next facility name from data file and determine if it
$ ! needs to be re-built with the exec (/EX qualifier).
$ !
$nxtcmd:
$ set noverify
$ read data cmd /end = exit
$ if "''f$extract(0,1,cmd)'" .eqs. "!" then goto nxtcmd
$ if 'f$locate("/EX",cmd)' .eq. 'f$length(cmd)' then goto nxtcmd
$ l = 'f$locate("	",cmd)		! search for end of name
$ if l .gt. 'f$locate(" ",cmd)' then l = 'f$locate(" ",cmd)'
$ facnam:='f$extract(0,l,cmd)
$ !
$ !	Create the directory if necessary
$ !
$ open/read/err=create temp 'P2'[sysobj.'facnam']com.dir;1
$ close temp
$ goto copy
$create:
$ create/directory 'P2'[sysobj.'facnam'.com]
$copy:
$ delete 'P2'[sysobj.'facnam'.com]*.*;*
$ copy/prot=(owner:rwed) masd$:['facnam'.com]*.* 'P2'[sysobj.'facnam'.com]
$ goto nxtcmd
$exit:
$ close data
$! reply /all "RESOBJ$ update complete."

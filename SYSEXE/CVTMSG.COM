$ !
$ !	Convert a single .MDL file to a .MSG file
$ !
$ !	P1 = Name of .MDL file to be converted
$ !
$ !	On output, the .MSG file is placed in the current default directory
$ !
$ ON WARNING THEN GOTO CLEANUP
$ OPEN/WRITE FILE FILES.DAT
$ WRITE FILE P1
$ CLOSE FILE
$ DEFINE SUBSYSIDS MASD$:[SYSMSG]SUBSYSIDS.DAT
$ RUN SYS$SYSTEM:CVTMSG
$CLEANUP:
$ DEASSIGN SUBSYSIDS
$ DELETE FILES.DAT;

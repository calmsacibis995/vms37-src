$ !
$ ! DRCOPYBLD
$ !
$ !	Assemble and link the files necessary to run DRCOPY.
$ !	DRCOPY is an example program for the DR780.  It requires
$ !	two DR780s;  it exemplifies a file transfer program between
$ !	two VAX machines.
$ !
$ FOR DRMASTER
$ FOR DRSLAVE
$ MACRO DRMAST
$ MACRO DRSLV
$ LINK /EXE=DRCOPY DRMASTER+DRSLAVE+DRMAST+DRSLV

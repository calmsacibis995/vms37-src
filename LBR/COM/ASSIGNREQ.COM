$ !
$ !	[ L B R . C O M ] L B R A S N R E Q . C O M
$ !
$ !	Commmand procedure to define require file logical names to compile
$ !	 the librarian access procedures.
$ !
$ DEFINE PREFIX SRC$:PREFIX.REQ
$ DEFINE LBRDEF LIB$:LBR.B32
$ DEFINE LBRMSG LIB$:LBRMSG.B32
$ DEFINE OLDFMTDEF LIB$:OLDLIBFMT.B32

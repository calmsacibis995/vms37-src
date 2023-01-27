$ !
$ !	[ L I B R A R . C O M ] L I B A S N R E Q . C O M
$ !
$ !	Commmand procedure to define require file logical names to compile
$ !	 the librarian command processor.
$ !
$ DEFINE	PREFIX		SRC$:PREFIX.REQ
$ DEFINE	LIBDEF		LIB$:LIB.B32
$ DEFINE	LBRDEF		LIB$:LBR.B32
$ DEFINE	LBRMSG		LIB$:LBRMSG.B32
$ DEFINE	OLDFMTDEF	LIB$:OLDLIBFMT.B32
$ DEFINE	CRFMDL		LIB$:CRFMDL.B32

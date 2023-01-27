$ !
$ !	[ P F M . C O M ] P F M W R T L N K . C O M
$ !
$ !	Link the page fault monitor file writer
$ !
$ LINK /NOTRACE /EXE=EXE$:PFMFILWRT /MAP=MAP$:PFMFILWRT /FULL /CROSS /NOUSERLIB -
	LIB$:PFM/INCLUDE=(PFMFILWRT), EXSM:SYS.STB/SELECTIVE

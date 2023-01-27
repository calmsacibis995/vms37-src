$ !
$ !	[ P F M . C O M ] P F M A N L L N K . C O M
$ !
$ !	Link the page fault monitor analyzer
$ !
$ T := /NOTRACE
$ IF P1 .NES. "" THEN T := /DEBUG
$ LINK 'T' /EXE=EXE$:PFMANALYZ /MAP=MAP$:PFMANALYZ /FULL /CROSS /NOUSERLIB -
	LIB$:PFM/INCLUDE=(PFM_ANALYZ)/LIBRARY

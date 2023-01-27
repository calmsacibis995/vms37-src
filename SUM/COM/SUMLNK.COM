$ !
$ !	[ S U M . C O M ] S U M L N K . C O M
$ !
$ ! Command file to link Source Update Merge
$ !
$ DELETE EXE$:SUM.EXE;*, MAP$:SUM.MAP;*
$ LINK /EXE=EXE$:SUM /MAP=MAP$:SUM /FULL /NOTRACE LIB$:SUM -
	/INCLUDE=(SUM, SUMFILES, SUMED)

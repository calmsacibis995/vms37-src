$ !
$ ! Link DISKQ
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:diskq.exe;*, map$:diskq.map;*
$ link /exe=exe$:diskq /map=map$:diskq/full/cross  /'qual' -
	lib$:util32/include=(diskq),-
	exsm:sys.stb/selective

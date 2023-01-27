$ !
$ ! Link SETUSER
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:setuser.exe;*, map$:setuser.map;*
$ link /exe=exe$:setuser /map=map$:setuser/full/cross  /'qual' -
	lib$:util32/include=(setuser),-
	exsm:sys.stb/selective

$ !
$ ! Link CHECKSUM
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:checksum.exe;*, map$:checksum.map;*
$ link /exe=exe$:checksum /map=map$:checksum/full/cross  /'qual' -
	lib$:util32/include=(checksum_image,cksmmsg)

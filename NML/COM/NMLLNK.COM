$ !
$ !	Link NML.EXE
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:nml.exe;*, map$:nml.map;*
$ link /exe=exe$:nml /map=map$:nml/full/cross -
	/'qual'  -
	lib$:nml/include=nml$main, -		! Only NMLMAIN module
	sys$input/options
exe$:nmlshr/share

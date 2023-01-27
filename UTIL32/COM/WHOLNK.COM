$ !
$ ! Link WHO
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:who.exe;*, map$:who.map;*
$ link /exe=exe$:who /map=map$:who/full/cross  /'qual' -
	lib$:util32/include=(who,readuaf), -
	resobj$:f11bacp/include=matchname, -
	sys$input/options
sys$library:lbrshr/share

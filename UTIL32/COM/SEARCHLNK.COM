$ !
$ ! Link SEARCH
$ !
$ qual := notrace
$ if p1 .nes. "" then qual := debug
$ delete exe$:search.exe;*, map$:search.map;*
$ link  /exe=exe$:search /map=map$:search/full/cross /'qual' -
	lib$:util32/include=(search,searchmsg),sys$input/option
STACK=40

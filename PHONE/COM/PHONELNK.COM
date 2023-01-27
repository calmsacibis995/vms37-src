$!
$!	[ P H O N E . C O M ] P H O N E L N K . C O M
$!
$	delete exe$:phone.exe;*, map$:phone.map;*
$	link/notraceback -
	    /executable=exe$:phone -
	    /map=map$:phone/full/cross_reference -
			lib$:phone/library/include=phone,sys$input/option
!
! Options input
!
psect=$plit$,exe

$ !
$ !	Link the command database image MCRTABLES
$ !
$ DELETE EXE$:MCRTABLES.EXE;*,MAP$:.MAP;*,EXE$:.STB;*
$ LINK /SHARE=EXE$:MCRTABLES /NOTRACE -
	/SYMBOL=EXE$:MCRTABLES -
	/MAP=MAP$:MCRTABLES/FULL/CROSS -
	SYS$INPUT:/OPTIONS
LIB$:MCR/INCLUDE=MCRDBAS
GSMATCH=LEQUAL,4,0		! MATCH VERSION 4 OR LATER
UNIVERSAL=MCR$AL_TAB_VEC,IMG_K_EXTIMAGE

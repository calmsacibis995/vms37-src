$ !
$ ! [DRIVER.COM]DRIVERLNK.COM - Command file to link loadable drivers.
$ !
$ DELETE EXE$:'P1'DRIVER.EXE;*, MAP$:'P1'DRIVER.MAP;*
$ LINK/NOSYSSHR/NOTRACEBACK/NODEBUG/SHARE=EXE$:'P1'DRIVER/CONTIGUOUS -
	/MAP=MAP$:'P1'DRIVER/FULL/CROSS -
	'P2' LIB$:DRIVER/INCLUDE='P1'DRIVER, -
	EXSM:SYS.STB/SELECTIVE,SYS$INPUT/OPTION
BASE=0

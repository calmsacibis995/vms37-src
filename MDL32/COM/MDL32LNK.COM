$ !
$ ! MDL32LNK.COM - COMMAND FILE TO LINK MDL32
$ !
$ IF 'F$LENGTH(P1) .NE. 0 THEN P1:=/'P1'
$ LINK /NOTRAC'P1'/EXE=EXE$:MDL32/MAP=MAP$:MDL32/FULL/CROSS OBJ$:MDL32

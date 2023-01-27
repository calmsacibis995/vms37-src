$ !
$ !	Update sources with SLP changes
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE ERRDEF.MDL

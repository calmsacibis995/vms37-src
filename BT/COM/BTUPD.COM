$ !
$ !	Update sources with SLP changes
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE BTMACROS.MAR
$ SRCUPDATE BTMSG.MDL
$ SRCUPDATE BTMSGS.MSG

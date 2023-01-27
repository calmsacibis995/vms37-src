$ !
$ !	[IOSUP.COM]IOSUPUPD.COM
$ !
$ !	Update require file sources with SLP changes.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE DRDEF.MAR
$ SRCUPDATE XFDEF.FOR

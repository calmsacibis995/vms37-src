$ !
$ !	Update require file sources with SLP changes
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE SOS.HLP
$ SRCUPDATE SOSREQ.B16
$ SRCUPDATE PREFIX.MAC

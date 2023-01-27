$ ! ASSIGNREQ.COM		! Define REQUIRE logical names
$ !
$ assign sys$library: nxport
$ assign SRC$: req

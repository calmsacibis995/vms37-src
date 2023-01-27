$ !
$ !	Assemble one module onto result disk
$ !
$ ! p1	facility
$ ! p2	module
$ ! p3	result disk
$ ! p4  BUG or ENH, default ENH
$ !
$ prev_default = f$logical("SYS$DISK") + f$directory()
$ set default ['p1']
$ IF 'F$LOCATE (":",p3) .EQ. 'F$LENGTH(p3) THEN p3 := 'p3':
$ if p4 .eqs. "" then p4 = "ENH"
$ updates := 'p4'		! For BLDLOGNAM procedure
$ @sysbldcom$:bldlognam 'p3' 'F$LOGICAL("MASD$")
$ if p1 .eqs. "RTL" then @com$:rtllognam assign
$ @sysbldcom$:fasm 'p1' 'p2' YES 'updates'
$ if p1 .eqs. "RTL" then @com$:rtllognam deassign
$ @sysbldcom$:bldeasnam
$ set default 'prev_default'

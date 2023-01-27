$!
$! [MOUNT.COM]MOUNTLNK.COM - COMMAND FILE TO LINK MOUNT COMMAND
$!
$! Note that the MOUNT command needs to link against the $MOUNT
$! system service, which is in the shareable image MOUNTSHR.EXE, which
$! in turn is located in IMAGELIB.OLB.
$!
$ LINK/NOTRACE/SYSSHR/EXE:EXE$:VMOUNT/MAP:MAP$:VMOUNT/FULL/CROSS -
	 LIB$:VMOUNT/INCLUDE:(MOUNTIMG)

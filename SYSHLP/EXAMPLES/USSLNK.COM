$!
$!	Command file to link User System Service example.
$!
$ LINK/PROTECT/NOSYSSHR/SHARE=USS/MAP=USS/FULL SYS$INPUT/OPTIONS
!
!	Options file for the link of User System Service example.
!
	SYS$SYSTEM:SYS.STB/SELECTIVE
!
!	Create a separate cluster for the transfer vector.
!
CLUSTER=TRANSTER_VECTOR,,,SYS$DISK:[]USSDISP
!
GSMATCH=LEQUAL,1,1

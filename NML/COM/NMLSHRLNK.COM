$ !
$ !	Link NMLSHR sharable image
$ !
$ delete exe$:nmlshr.exe;*, map$:nmlshr.map;*
$ link /share=exe$:nmlshr /map=map$:nmlshr/full/cross -
	/notrace /nosysshr -
	lib$:nml/lib/include=nml$entry, -
	sys$input/options
!
! Put the transfer vector in its own cluster at the beginning
!
CLUSTER=TRANSFER_VECTOR,,,LIB$:NML/INCLUDE=NML$TRANSFER
!
! Set Global Section match control
!
GSMATCH=LEQUAL,3,0
!
! Define universal symbols
!
UNIVERSAL= -
NML$INITIALIZE,-	! Initialize NICE processor
NML$PROCESS_NICE,-	! Process a single NICE message
NML$TERMINATE,-		! Terminate NICE processor
NML$AUTO_SERVICE	! MOP auto-service functions
PSECT = _LIB$CODE,NOPIC,NOSHR
PSECT = _LIB$DATA,NOPIC

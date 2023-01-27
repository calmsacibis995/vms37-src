$ !
$ ! [ R U F . C O M ] R U F S H R L N K . C O M
$ !
$ !	Link the shareable image of recovery-unit facility procedures
$ !
$ !DELETE EXE$:RUFSHR.EXE;*, EXE$:RUFSHR.STB;*, MAP$:RUFSHR.MAP;*
$ LINK /NOSYSSHR /SHARE=EXE$:RUFSHR /MAP=MAP$:RUFSHR /FULL/CROSS -
	/PROTECT/SYMBOL=EXE$:RUFSHR SYS$INPUT:/OPTIONS
!
! Options for RUFSHRLNK.COM
!
EXSM:SYS.STB/SELECT
!
! Put the transfer vector in its own cluster
!
CLUSTER=TRANSFER_VECTOR,,,LIB$:RUF/INCLUDE=RUFVECTOR
CLUSTER=SERVICE_CODE,,,LIB$:RUF/INCLUDE=RUFSYSSRV
CLUSTER=SERVICE_DATA,,,LIB$:RUF/INCLUDE=RUFDATA
!
!************************************************************************
!  Debugging hack to allow writeable privileged library sections for
!  setting breakpoints and other such foolishness.
!
PSECT_ATTR=RUF$TRANSFER_VECTOR,WRT,NOSHR
PSECT_ATTR=RUF$KRNL_DISP0,WRT,NOSHR
PSECT_ATTR=RUF$KRNL_DISP1,WRT,NOSHR
PSECT_ATTR=RUF$KRNL_DISP2,WRT,NOSHR
PSECT_ATTR=RUF$CODE,WRT,NOSHR
!************************************************************************
!
! Set Global Section match control
!
GSMATCH=LEQUAL,1,1
!
! Define universal symbols
!
UNIVERSAL= -
RUF$START,-		! Start RU service
RUF$PH1_END,-		! Phase 1 RU service
RUF$PH2_END,-		! Phase 2 RU service
RUF$END,-		! Phase 1 and phase 2 RU services
RUF$CANCEL,-		! Cancel RU service
RUF$MARKPOINT,-		! Declare markpoint RU service
RUF$RESET,-		! Reset to markpoint RU service
RUF$DCLRUH,-		! Declare RU handler RU service
RUF$CANRUH,-		! Cancel RU handler RU service
RUF$MODIFY		! Modify RU service

$ !
$ !	[ DSC.COM] D S C A S M . C O M
$ !
$ !  Command file to assemble all modules for DSC1 and DSC2
$ !
$ !	Assemble modules for DSC1
$ !
$ MCR MAC
OBJ$:DSCPAR.OB1,LIS$:DSCPAR.LS1/-SP=SRC$:SMAC/PA:1,DSCPRE,OD1DSCPAR
;
; Assemble common modules and modules for DSC2
;
OBJ$:DSC,LIS$:DSC/-SP=SRC$:SMAC/PA:1,DSCPRE,DSC
OBJ$:DSCDAT,LIS$:DSCDAT/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCDAT
OBJ$:BLDRP,LIS$:BLDRP/-SP=SRC$:SMAC/PA:1,DSCPRE,BLDRP
OBJ$:CKSUM,LIS$:CKSUM/-SP=SRC$:SMAC/PA:1,DSCPRE,CKSUM
OBJ$:DCREA,LIS$:DCREA/-SP=SRC$:SMAC/PA:1,DSCPRE,DCREA
OBJ$:DFIND,LIS$:DFIND/-SP=SRC$:SMAC/PA:1,DSCPRE,DFIND
OBJ$:DLHDD,LIS$:DLHDD/-SP=SRC$:SMAC/PA:1,DSCPRE,DLHDD
OBJ$:DLHDR,LIS$:DLHDR/-SP=SRC$:SMAC/PA:1,DSCPRE,DLHDR
OBJ$:DRDDA,LIS$:DRDDA/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDDA
OBJ$:DRDDO,LIS$:DRDDO/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDDO
OBJ$:DRDEX,LIS$:DRDEX/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDEX
OBJ$:DRDID,LIS$:DRDID/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDID
OBJ$:DRDSO,LIS$:DRDSO/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDSO
OBJ$:DRDSU,LIS$:DRDSU/-SP=SRC$:SMAC/PA:1,DSCPRE,DRDSU
OBJ$:DSCAL,LIS$:DSCAL/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCAL
OBJ$:DSCBD,LIS$:DSCBD/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCBD
OBJ$:DSCBT,LIS$:DSCBT/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCBT
OBJ$:DSCER,LIS$:DSCER/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCER
OBJ$:DSCIO,LIS$:DSCIO/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCIO
OBJ$:DSCPAR,LIS$:DSCPAR/-SP=SRC$:SMAC/PA:1,DSCPRE,DSCPAR
OBJ$:DWTDA,LIS$:DWTDA/-SP=SRC$:SMAC/PA:1,DSCPRE,DWTDA
OBJ$:DWTID,LIS$:DWTID/-SP=SRC$:SMAC/PA:1,DSCPRE,DWTID
OBJ$:DWTSU,LIS$:DWTSU/-SP=SRC$:SMAC/PA:1,DSCPRE,DWTSU
OBJ$:FILSZ,LIS$:FILSZ/-SP=SRC$:SMAC/PA:1,DSCPRE,FILSZ
OBJ$:MPVBN,LIS$:MPVBN/-SP=SRC$:SMAC/PA:1,DSCPRE,MPVBN
OBJ$:RDHDR,LIS$:RDHDR/-SP=SRC$:SMAC/PA:1,DSCPRE,RDHDR
OBJ$:SMALC,LIS$:SMALC/-SP=SRC$:SMAC/PA:1,DSCPRE,SMALC
OBJ$:SMNXB,LIS$:SMNXB/-SP=SRC$:SMAC/PA:1,DSCPRE,SMNXB
OBJ$:SMRVB,LIS$:SMRVB/-SP=SRC$:SMAC/PA:1,DSCPRE,SMRVB
OBJ$:SMSCN,LIS$:SMSCN/-SP=SRC$:SMAC/PA:1,DSCPRE,SMSCN
OBJ$:STDEN,LIS$:STDEN/-SP=SRC$:SMAC/PA:1,DSCPRE,STDEN
OBJ$:SWDSK,LIS$:SWDSK/-SP=SRC$:SMAC/PA:1,DSCPRE,SWDSK
OBJ$:SWTAP,LIS$:SWTAP/-SP=SRC$:SMAC/PA:1,DSCPRE,SWTAP
OBJ$:TCREA,LIS$:TCREA/-SP=SRC$:SMAC/PA:1,DSCPRE,TCREA
OBJ$:TFIND,LIS$:TFIND/-SP=SRC$:SMAC/PA:1,DSCPRE,TFIND
OBJ$:TFINO,LIS$:TFINO/-SP=SRC$:SMAC/PA:1,DSCPRE,TFINO
OBJ$:TINI,LIS$:TINI/-SP=SRC$:SMAC/PA:1,DSCPRE,TINI
OBJ$:TINO,LIS$:TINO/-SP=SRC$:SMAC/PA:1,DSCPRE,TINO
OBJ$:TPRDY,LIS$:TPRDY/-SP=SRC$:SMAC/PA:1,DSCPRE,TPRDY
OBJ$:TRDDA,LIS$:TRDDA/-SP=SRC$:SMAC/PA:1,DSCPRE,TRDDA
OBJ$:TRDEX,LIS$:TRDEX/-SP=SRC$:SMAC/PA:1,DSCPRE,TRDEX
OBJ$:TRDID,LIS$:TRDID/-SP=SRC$:SMAC/PA:1,DSCPRE,TRDID
OBJ$:TRDSU,LIS$:TRDSU/-SP=SRC$:SMAC/PA:1,DSCPRE,TRDSU
OBJ$:TWTDA,LIS$:TWTDA/-SP=SRC$:SMAC/PA:1,DSCPRE,TWTDA
OBJ$:WBOOT,LIS$:WBOOT/-SP=SRC$:SMAC/PA:1,DSCPRE,WBOOT
OBJ$:WRHDR,LIS$:WRHDR/-SP=SRC$:SMAC/PA:1,DSCPRE,WRHDR
OBJ$:ZMAP,LIS$:ZMAP/-SP=SRC$:SMAC/PA:1,DSCPRE,ZMAP
OBJ$:GTCML,LIS$:GTCML/-SP=SRC$:SMAC/PA:1,DSCPRE,GTCML
OBJ$:CATDT,LIS$:CATDT/-SP=SRC$:SMAC/PA:1,DSCPRE,CATDT
OBJ$:GDTIM,LIS$:GDTIM/-SP=SRC$:SMAC/PA:1,DSCPRE,GDTIM
OBJ$:MONTB,LIS$:MONTB/-SP=SRC$:SMAC/PA:1,DSCPRE,MONTB
OBJ$:MULQ,LIS$:MULQ/-SP=SRC$:SMAC/PA:1,DSCPRE,MULQ
OBJ$:DIVD,LIS$:DIVD/-SP=SRC$:SMAC/PA:1,DSCPRE,DIVD

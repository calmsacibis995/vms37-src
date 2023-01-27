$ ! ************************ BUILD DEBUG MESSAGE FILE **************************
$ !
$ ! This command procedure takes the module SRC$:DBGMSG.MDL and produces
$ ! the module DBGMSG.OBJ.
$ !
$ COPY SRC$:DBGMSG.MDL []
$ @SYS$SYSTEM:CVTMSG DBGMSG.MDL
$ MESSAGE/OBJ=OBJ$:DBGMSG.OBJ DBGMSG
$ DELETE DBGMSG.MDL;0
$ DELETE DBGMSG.MSG;0

$ ! ************************ BUILD TRACE MESSAGE FILE **************************
$ !
$ ! This command procedure takes the module SRC$:TRACEMSG.MDL and produces
$ ! the module TRACEMSG.OBJ.
$ !
$ COPY SRC$:TRACEMSG.MDL []
$ @SYS$SYSTEM:CVTMSG TRACEMSG.MDL
$ MESSAGE/OBJ=OBJ$:TRACEMSG.OBJ TRACEMSG
$ DELETE TRACEMSG.MDL;0
$ DELETE TRACEMSG.MSG;0

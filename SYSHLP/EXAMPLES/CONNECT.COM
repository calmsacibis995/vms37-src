!FILE:CONNECT.COM
! This command file loads the connect-to-interrupt handler (CONINTERR) and
! then connects the KW11-K to to it.
! 
$ R SYS$SYSTEM:SYSGEN
LOAD CONINTERR			
CONNECT KWA0 /ADAPTER=3/CSR=%O770444/VEC=%O404/DRIVER=CONINTERR
$ Exit


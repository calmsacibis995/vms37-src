!File:	LABIOCOMP.COM
! Indirect command file to compile and assembly
! the modules of the LABIO system.

$ Fortran LABIOACQ,LABIOCON,LABIOSTAT,LABIOCOM,LABIOSEC
$ Macro/List LABIOCIN+Sys$Library:LIB.MLB/Library
$ Macro/List GBLSECUFO
$! Demo Programs
$ Fortran LABIOSAMP,LABIOPEAK,PEAK,TESTLABIO

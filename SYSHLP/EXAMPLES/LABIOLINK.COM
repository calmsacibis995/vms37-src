!File:	LABIOLINK.COM
! Indirect Comamnd file to LINK the LABIO system
$ Link/Map LABIOACQ,GBLSECUFO,LABIOCOM,LABIOCIN/Option
$ Link/Map LABIOCON,LABIO/Option
$ Link/Map LABIOSTAT,LABIO/Option
$! Demo Programs
$ Link/Map LABIOPEAK,PEAK,LABIO/Opt
$ Link/Map LABIOSAMP,LABIO/Opt
$ Link/Map TESTLABIO,LABIO/OPt

$ oldvfy='f$verify(0)'
$ !
$ ! TKBLPG.COM - Task Build and generate lines-per-page data
$ !
$ !	Build a compatiblity mode program twice with different
$ ! values for the number of lines per page in the listing format.
$ ! Run a binary compare between the resulting images and generate
$ ! a data file from which they can be automatically patched for
$ ! a different size printer page.
$ !	This procedure produces EXE$:xxx.EXE and MAP$:xxx.MAP
$ ! as would normally have come from building the program.  It
$ ! also generates EXE$:xxxLPG.DAT for use in patching xxx.EXE
$ ! for a printer with a non-standard number of lines per page.
$ ! This data file is input to SYS$UPDATE:LINEPAGE.COM.
$ !
$ !	p1 = image name being built (e.g. MAC, TKB)
$ !	p2 = build command file name (e.g. BIGMACBLD, TKBLNK)
$ !	p3 = GBLPAT/GBLDEF symbol name (e.g. LINPPG, "P$LNTH")
$ !	p4 = maximum valid severity level for errors from TKB
$ !	     (used by SOS to allow for PSECT conflict errors)
$ !
$ !	Note that the following edits the build command file and
$ ! produces a scratch copy with a -1 value for lines-per-page
$ !
$ if p4 .eqs. "" then p4=1
$ sev=1
$ alt:=#
$ open /write out tmp$:editlpg.com
$ write out "$DEFINE /USER SYS$OUTPUT NL:"
$ write out "$EDIT /SOS /OUT=TMP$:''P2'.LPG COM$:''P2'.CMD"
$ write out "/MAT"
$ write out "SEXE$:''P1'''ALT'TMP$:''P1'LPG''ALT'"
$ write out "S?>?1?/,?1?/=''ALT'?*1?*=''ALT'."
$ write out "S?>?1?/''P3':?1?/?>''ALT'?*1?*''P3':177777''alt'"
$ write out "S?>?1?/GBL''ALT'GBL''ALT'."
$ write out "E"
$ close out
$ define /user sys$output nl:
$ edit /sos tmp$:editlpg.com
/alt
s#$/.
eb
$ @tmp$:editlpg
$ set noon
$ mcr tkb @com$:'p2'
$ sev=$severity
$ if sev .gt. p4 then goto abort
$ mcr tkb @tmp$:'p2'.lpg
$ sev=$severity
$ if sev .gt. p4 then goto abort
$ set on
$ sev=1
$ define /user sys$output exe$:'p1'lpg.dat
$ define /user for001 exe$:'p1'.exe
$ define /user for002 tmp$:'p1'lpg.exe
$ run sysbldcom$:bincomlpg
$ open /write out tmp$:editlpg.com
$ write out "i50"
$ write out "*''p1'"
$ close out
$ define /user sys$output nl:
$ mcr sos /nolin/start:100/step:100/noseq/nobak, exe$:'p1'lpg.dat
@tmp$:editlpg.com
$ delete tmp$:editlpg.com;*,'p1'lpg.exe;*,'p2'.lpg;*
$abort:
$ if oldvfy then set verify
$ exit sev

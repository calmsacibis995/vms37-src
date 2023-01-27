$ v = f$verify(0)
$ set noon
$ library/list=lib$:msglis.tmp srcd$:[sysmsg]sysmsg/text
$ sysfac = 1
$ module = "sysfac"
$ open/read f1 src$:sysfac.dat
$ goto next_mod2
$dolib:
$ open /read f0 lib$:msglis.tmp
$ read f0 line
$ read f0 line
$ read f0 line
$ read f0 line
$ read f0 line
$ read f0 line
$ read f0 line
$ read f0 line
$next_module:
$ read /end=endlib f0 module
$ libr /extract='module'/out=lib$:'module'.tmp srcd$:[sysmsg]sysmsg/text
$ if .not. $status then goto next_module
$ open /read f1 lib$:'module'.tmp
$next_mod2:
$ open /write f2 lib$:'module'.tmp
$10:
$ read /end=done f1 line
$ if f$extract(0,1,line) .eqs. "	" then line = f$extract(1,999,line)
$ l1 = f$length(line)
$ if l1 .eq. 0 then goto 10
$ if f$extract(0,1,line) .eqs. "!" then goto 10
$ if f$locate("!",line) .eq. l1 then goto writeline
$ if f$locate("<",line) .ne. l1 then goto writeline
$ if f$locate("""",line) .ne. l1 then goto writeline
$ tline := 'line
$ if f$length(tline) .eq. 0 then goto 10
$writeline:
$ write f2 line
$ goto 10
$done:
$ close f1
$ close f2
$ if .not. sysfac then goto next_module
$ sysfac = 0
$ goto dolib
$nofile:
$ write sys$output "No file."
$ goto out
$endlib:
$ close f0
$ library/create=(modu=5) srcd$:[sysmsg]sysmsg/text -
 lib$:*msg.tmp,lib$:sysfac.tmp
$ delete lib$:*.tmp;*
$out:
$ if v then set verify
$ exit

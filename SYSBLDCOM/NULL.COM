$ !
$ !	Do nothing - this command procedure is used to equate
$ !	a system build verb such as cpyreslss to here to disable
$ !	any call to such a verb.  Any parameters given to the
$ !	verb will come in here as p1 thru p8 and be ignored.
$ !
$ EXIT

$ ! Link Sharable Run-time Library 
$ ! 0-2 Add instructions to make experimental shared library.  TNH 27-July-78
$ ! 1-3 - Add IMAGETEST.  SBL 24-Apr-79
$ ! 1-004 - Link a second library so we can be sure they are PIC.
$ !	     JBS 13-SEP-1979
$ ! 1-005 - But only do it if we are testing!  SBL 21-Sept-1979
$ ! 1-006 - Don't do it at all any more.  JBS 18-OCT-1979
$ ! 1-007 - Remove IMAGETEST.  SBL 2-Dec-1981
$ !--
$ DELETE EXE$:VMSRTL.EXE;*, MAP$:VMSRTL.MAP;*
$ LINK/NOSYSLIB/SHARE=EXE$:VMSRTL/MAP=MAP$:VMSRTL/FULL/CROSS-
	COM$:VMSRTLLNK/OPTIONS
$ !
$ !	[ End of file VMSRTLLNK.COM ]

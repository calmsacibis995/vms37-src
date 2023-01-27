$ !
$ ! Insert shareable images into IMAGELIB
$ !
$ ! INPUTS:
$ !
$ ! P1	- filename string for IMAGELIB
$ ! P2  - file list of input shareable images
$ !
$ LIBRARY /SHARE 'P1' 'P2'

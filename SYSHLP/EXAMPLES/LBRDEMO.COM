$ fortran lbrdemo
$ macro lbrmac
$ link /notrace lbrdemo, lbrmac

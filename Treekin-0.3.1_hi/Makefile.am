
bin_PROGRAMS = treekin_hi

treekin_hi_SOURCES = main.c\
                  globals.c     globals.h\
                  calc.c        calc.h\
                  mxccm.c       mxccm.h\
                  barparser.c   barparser.h\
                  exp_matrix.c  exp_matrix.h\
                  treekin_cmdline.c treekin_cmdline.h

EXTRA_DIST = VERSION.txt treekin.ggo treekin_cmdline.c treekin_cmdline.h

globals.c:  treekin_cmdline.h

treekin_cmdline.h treekin_cmdline.c:  treekin.ggo
	gengetopt -i treekin.ggo



# End of file

# Produced by CVXGEN, 2014-05-20 16:06:21 -0400.
# CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com.
# The code in this file is Copyright (C) 2006-2012 Jacob Mattingley.
# CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial
# applications without prior written permission from Jacob Mattingley.

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)
$(shell mkdir -p $(BUILD_PREFIX)/lib/python2.7/dist-packages/irispy)

OPT = -Wall
OPT=-Os
LDLIBS = -lm
CFLAGS = $(OPT) $(INCLUDES)
CC = gcc
SRC = solver.c matrix_support.c ldl.c util.c cvxgen_ldp.c
.PHONY: all
all: testsolver install
testsolver: solver.o matrix_support.o ldl.o testsolver.o util.o
# Include util.o for random functions and easy matrix printing.
#testsolver: solver.o matrix_support.o ldl.o util.o testsolver.o
solver.o: solver.h
matrix_support.o: solver.h
ldl.o: solver.h
util.o: solver.h
testsolver.o: solver.h
cvxgen_ldp.so: solver.o matrix_support.o ldl.o util.o cvxgen_ldp.c
	$(CC) $(CFLAGS) -fPIC $(LDLIBS) -shared -o cvxgen_ldp.so $(SRC)
.PHONY : clean
clean :
	-rm -f *.o testsolver cvxgen_ldp.so

install: $(BUILD_PREFIX)/lib/python2.7/dist-packages/irispy/cvxgen_ldp.so $(BUILD_PREFIX)/matlab/csolve.mex*64

$(BUILD_PREFIX)/lib/python2.7/dist-packages/irispy/cvxgen_ldp.so: cvxgen_ldp.so
	cp cvxgen_ldp.so $(BUILD_PREFIX)/lib/python2.7/dist-packages/irispy/

$(BUILD_PREFIX)/matlab/csolve.mex*64:
	matlab -nosplash -nodesktop -r "make_csolve; quit();"
	cp csolve.mex*64 $(BUILD_PREFIX)/matlab/


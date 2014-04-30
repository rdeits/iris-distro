default_target: all

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to two parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX=$(shell for pfx in ./ .. ../..; do d=`pwd`/$$pfx/build; \
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# create the matlab build directory
$(shell mkdir -p $(BUILD_PREFIX)/matlab)

all:
	cp -r $(shell pwd)/+iris $(BUILD_PREFIX)/matlab/

clean:
	rm -r $(BUILD_PREFIX)/matlab/+iris
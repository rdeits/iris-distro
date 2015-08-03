# Default pod makefile distributed with pods version: 12.11.14

default_target: all

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
# create the matlab build directory
$(shell mkdir -p $(BUILD_PREFIX)/matlab)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

test: 
	$(MAKE) -C pod-build/iris_project-prefix/src/iris_project-build test

.PHONY: all
all: pod-build/Makefile

pod-build/Makefile:
	$(MAKE) configure

.PHONY: options
options: configure
ifeq ($(OS),Windows_NT)	
	cmake-gui pod-build
else
	ccmake pod-build
endif

.PHONY: configure
configure: 
#	@echo "BUILD_SYSTEM: '$(BUILD_SYSTEM)'"
	@echo "BUILD_PREFIX: $(BUILD_PREFIX)"

# create the temporary build directory if needed
# create the lib directory if needed, so the pkgconfig gets installed to the right place
ifeq ($(BUILD_SYSTEM), Windows_NT)
	@if not exist pod-build ( mkdir pod-build )
else
	@mkdir -p pod-build
endif

# run CMake to generate and configure the build scripts
	@cd pod-build && cmake $(CMAKE_FLAGS) -DCMAKE_INSTALL_PREFIX=$(BUILD_PREFIX) \
	       	-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..

clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -e $(BUILD_PREFIX)/matlab/+iris ]; then rm -rf $(BUILD_PREFIX)/matlab/+iris; fi
	-if [ -d pod-build ]; then $(MAKE) -C pod-build clean; rm -rf pod-build; fi

# other (custom) targets are passed through to the cmake-generated Makefile
%::
	$(MAKE) -C pod-build $@
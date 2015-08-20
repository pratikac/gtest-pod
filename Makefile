GIT_DL_LINK :=  https://chromium.googlesource.com/external/googletest

default_target: all

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif

# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
OPT_FLAGS := #-g -O2
ifeq "$(BUILD_TYPE)" "Debug"
OPT_FLAGS = -g
endif

.PRECIOUS: download
download:
	@echo "\nDownloading googletest \n\n"
	git clone $(GIT_DL_LINK)
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"

all: pod-build/Makefile
	$(MAKE) -C pod-build all install
pod-build/Makefile:
	$(MAKE) configure

.PHONY: configure
configure: download
	@echo "\nBUILD_PREFIX: $BUILD_PREFIX\n\n"
	
	# create pod-build
	@mkdir -p pod-build

	# run cmake
	@cd pod-build  && \
		cmake -DCMAKE_INSTALL_PREFIX=$(BUILD_PREFIX) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -d pod-build ]; then $(MAKE) -C pod-build clean; rm -rf pod-build; fi


# other (custom) targets are passed through to the cmake-generated Makefile
%::
	$(MAKE) -C pod-build $@

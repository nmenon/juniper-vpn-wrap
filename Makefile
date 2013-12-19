# Handle verbose

ifeq ("$(origin V)", "command line")
  VERBOSE = $(V)
endif
ifndef VERBOSE
  VERBOSE = 0
endif
Q := $(if $(VERBOSE:1=),@)

JAVA_32=$(shell java -d64 -version 2>&1 |\
	 grep -q "is not supported on this platform" && echo -m32)

BUILD_DEPS="build-essential lib32asound2 ia32-libs ia32-sun-java6-bin \
	    gcc-multilib python-mechanize\
	    libevent-2.0-5:i386 libevent-core-2.0-5:i386 libevent-extra-2.0-5:i386 libevent-dev:i386\
	    libpcap0.8:i386 libpcap0.8-dev:i386"

# Phony rules
.PHONY: all distclean clean git gitsync lwip ncsvc

all: check_generic_packages lwip ncsvc

git:
	$(Q)git submodule status|grep '^-' && git submodule init && \
		git submodule update || echo 'submodule: nothin to update'

gitsync:
	$(Q)git submodule init && git submodule sync && \
		git submodule update || echo 'submodule: nothin to update'

clean: clean_lwip clean_ncsvc

distclean: clean

clean_lwip:
	$(Q)make -C lwip clean

clean_ncsvc:
	$(Q)make -C ncsvc-socs-wrapper clean

lwip:
	$(Q)make -C lwip

ncsvc: lwip
	$(Q)make LWIP=$(PWD)/lwip -C ncsvc-socs-wrapper install


check_generic_packages: check_java_32

check_java_32:
	$(Q)if [ -z "$(JAVA_32)" ]; then echo "Need 32 bit java: verify with 'java -d64 -version' - run sudo $(PWD)/oab-java6/oab-java6.sh && sudo apt-get install ia32-sun-java6-bin"; exit 1; fi

install_ubuntu_packages:
	$(Q)sudo apt-get install  $(shell eval echo $(BUILD_DEPS))

# A top-level Makefile to compile all X10 sources

# <BEGIN> user settings #

export X10CXX 		?= x10c++

#leave blank by default, let x10c++ choose a sensible default
export X10RTTRANSPORT	?= -x10rt pami

export X10CXXFLAGS 	?= -report postcompile=5 $(X10RTTRANSPORT)



# <END> user settings #

ifeq ($(shell uname -s),AIX)
   include arch/aix.mk
endif
ifeq ($(shell uname -s),Linux)	
	ifeq ($(shell uname -p),ppc64)
		include arch/linux_ppc64.mk
	else
		include arch/linux.mk
	endif
endif
ifeq ($(shell uname -s),Darwin)
   include arch/darwin.mk
endif
ifeq ($(firstword $(subst _, ,$(shell uname -s))),CYGWIN)
   include arch/cygwin.mk
endif
ifeq ($(BGP_CROSS_COMPILE), 1)
   include arch/bgp.mk
endif


all: all_dbg all_opt all_exp

all_dbg: LU-dbg \
	STREAM-dbg \
	RA-dbg\
        FT-alltoall-dbg

all_opt: LU-opt \
	STREAM-opt \
	RA-opt \
        FT-alltoall-opt

all_exp: LU-exp \
	STREAM-exp \
	RA-exp \
        FT-alltoall-exp

FT: FT-opt FT-dbg

FT-opt:
	$(MAKE) -C FT fft-opt

FT-dbg:
	$(MAKE) -C FT fft-dbg

FT-clean:
	$(MAKE) -C FT clean

LU: LU-opt LU-dbg

LU-opt:
	$(MAKE) -C LU lu-opt

LU-exp:
	$(MAKE) -C LU lu-exp

LU-dbg:
	$(MAKE) -C LU lu-dbg

LU-clean:
	$(MAKE) -C LU clean

STREAM: STREAM-opt STREAM-dbg

STREAM-opt:
	$(MAKE) -C STREAM stream-opt

STREAM-exp:
	$(MAKE) -C STREAM stream-exp

STREAM-dbg:
	$(MAKE) -C STREAM stream-dbg

STREAM-clean:
	$(MAKE) -C STREAM clean

RA: RA-opt RA-dbg

RA-opt:
	$(MAKE) -C RA ra-opt

RA-exp:
	$(MAKE) -C RA ra-exp

RA-dbg:
	$(MAKE) -C RA ra-dbg

RA-clean:
	$(MAKE) -C RA clean

FT-alltoall: FT-alltoall-opt FT-alltoall-dbg

FT-alltoall-opt:
	$(MAKE) -C FT-alltoall fft-opt

FT-alltoall-exp:
	$(MAKE) -C FT-alltoall fft-exp

FT-alltoall-dbg:
	$(MAKE) -C FT-alltoall fft-dbg

FT-alltoall-clean:
	$(MAKE) -C FT-alltoall clean

FT-comm: FT-comm-opt FT-comm-dbg

FT-comm-opt:
	$(MAKE) -C FT-comm fft-opt

FT-comm-exp:
	$(MAKE) -C FT-comm fft-exp

FT-comm-dbg:
	$(MAKE) -C FT-comm fft-dbg

FT-comm-clean:
	$(MAKE) -C FT-comm clean

FT-global-opt:
	$(MAKE) -C FT-global fft-opt

FT-global-dbg:
	$(MAKE) -C FT-global fft-dbg

FT-global-clean:
	$(MAKE) -C FT-global clean

clean: FT-clean LU-clean STREAM-clean RA-clean FT-alltoall-clean FT-comm-clean FT-global-clean

.PHONY: FT LU STREAM RA
.PHONY: clean

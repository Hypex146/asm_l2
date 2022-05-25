CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = prog2.s

CPP = cpp_$(SRCS)

ifdef REV


ifeq ($(REV), true)
DEF = -DREV
else
ifeq ($(REV), false)
DEF =
else
error:
	@echo "ERROR. REV = true / false !"
endif
endif

else
DEF =
endif

OBJS = $(CPP:.s=.o)

EXE = prog2

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS) $(CPP)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(OBJS): $(CPP)
	$(AS) $(ASFLAGS) $< -o $@

$(CPP):
	aarch64-linux-gnu-cpp $(DEF) $(SRCS) -o $(CPP)

ROOTDIR = $(N64_INST)
GCCN64PREFIX = $(ROOTDIR)/bin/mips64-elf-
CHKSUM64PATH = $(ROOTDIR)/bin/chksum64
MKDFSPATH = $(ROOTDIR)/bin/mkdfs
HEADERPATH = $(ROOTDIR)/lib
N64TOOL = $(ROOTDIR)/bin/n64tool
HEADERNAME = header


LINK_FLAGS = -G4 -L$(ROOTDIR)/toolchain_font/lib -L$(ROOTDIR)/mips64-elf/lib -ldragon -L$(ROOTDIR)/toolchain_font/lib  -lmikmod -lmad -lc -lm -ldragonsys -lnosys $(LIBS) -Tn64ld.x 
PROG_NAME = menu
CFLAGS = -std=gnu99 -march=vr4300 -mtune=vr4300  -G4  -I$(ROOTDIR)/toolchain_font/include -I$(ROOTDIR)/mips64-elf/include  -lpthread -lrt -D_REENTRANT -DUSE_TRUETYPE
ASFLAGS = -mtune=vr4300 -march=vr4300
CC = $(GCCN64PREFIX)gcc
AS = $(GCCN64PREFIX)as
LD = $(GCCN64PREFIX)ld
OBJCOPY = $(GCCN64PREFIX)objcopy
OBJS = $(PROG_NAME).o everdrive.o fat.o disk.o mem.o sys.o ini.o strlib.o utils.o sram.o stb_image.o chksum64.o mp3.o

$(PROG_NAME).v64: $(PROG_NAME).elf test.dfs
	$(OBJCOPY) $(PROG_NAME).elf $(PROG_NAME).bin -O binary
	rm -f $(PROG_NAME).v64
	$(N64TOOL) -l 4M -t "EverDrive OS" -h ./header.ed64 -o OS64.v64 $(PROG_NAME).bin -s 1M test.dfs
	$(CHKSUM64PATH) OS64.v64

$(PROG_NAME).elf : $(OBJS)
	$(LD) -o $(PROG_NAME).elf $(OBJS) $(LINK_FLAGS)

copy: $(PROG_NAME).v64
	sh upload.sh

test.dfs:
	$(MKDFSPATH) test.dfs ./filesystem/

all: $(PROG_NAME).v64

clean:
	rm -f *.v64 *.elf *.o *.bin *.dfs

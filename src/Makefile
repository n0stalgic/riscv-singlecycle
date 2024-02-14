C_SRCS   = rv_test.c

VERILOG_SRCS = *.v

SYSTEM_VERILOG_SRCS = *.sv

VERILOG_HEADERS = opcode.vh
VERILOG_TOP     = riscv_sys

VERILATOR_CPP_SRC = riscv_test.cpp

VCD_FILE          = wave.vcd
GTKWAVE_FORMAT    = wave.gtkw

ARCH = rv32i
C_BASE   = rv_test

ELF_TARGET  = $(C_BASE).elf
BIN_TARGET  = $(C_BASE).bin

MAX_TRACE_ARRAY = 16384

CC = riscv32-unknown-elf-gcc
AS = riscv32-unknown-elf-as
OC = riscv32-unknown-elf-objcopy 
OD = riscv32-unknown-elf-objdump
VV = verilator


CCFLAGS = -march=$(ARCH) -g -ffunction-sections
OBJFLAGS = -j .text
VVFLAGS = -Wno-WIDTHEXPAND -Wno-MULTITOP -Wno-CASEINCOMPLETE --trace-max-array $(MAX_TRACE_ARRAY) --trace --exe --build 

OCFLAGS = -O binary $(OBJFLAGS)
DISASSEMBLER_FLAGS = no-aliases,numeric
ODFLAGS = -d $(OBJFLAGS) --adjust-vma=0x4 
ODOPTS  = --disassembler-options=$(DISASSEMBLER_FLAGS) 
LDFLAGS = -T $(C_BASE).ld -Wl,-Map=$(C_BASE).map -nostdlib

C_ELFS  = $(C_SRCS:.c=.elf)

$(ELF_TARGET) : $(C_SRCS)
	$(CC) -O0 $(CCFLAGS) $(LDFLAGS) $< -o $@
	$(OC) $(OCFLAGS) $@ $(BIN_TARGET)

.PHONY: disassemble_c
disassemble_c: $(C_ELFS)
	@echo "#------- C ALIASED DISASSEMBLY -----------#"
	$(OD) $(ODFLAGS) $<
	@echo "#------- END ALIASED C DISASSEMBLY -----------#"
	@echo "#------- C NON-ALIASED DISASSEMBLY -----------#"
	$(OD) $(ODOPTS) $(ODFLAGS) $<
	@echo "#------- END NON-ALIASED C DISASSEMBLY -----------#"
	

.PHONY: build
build: $(ELF_TARGET) disassemble_c

.PHONY: verilate
verilate: build
	$(VV) $(VVFLAGS) --cc $(VERILATOR_CPP_SRC) --top-module $(VERILOG_TOP) $(VERILOG_SRCS) $(SYSTEM_VERILOG_SRCS) $(VERILOG_HEADERS)

.PHONY: sim
sim:
	gtkwave $(VCD_FILE) $(GTKWAVE_FORMAT) &

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf *.bin
	rm -rf *.out
	rm -rf *.vcd
	rm -rf *.map
	rm -rf *.elf
	rm -rf obj_dir/

# Colorlight 5A-75B FPGA GPIO test Makefile Project
#
# File types:
# *.sv           - SystemVerilog design source files
# *.svh          - SystemVerilog design source include headers
# *.json         - intermediate representation for FPGA deisgn from yosys
# *.bin          - final binary "bitstream" output file used to program FPGA

# This is a "make hack" have make exit if command fails (even if command after pipe succeeds, e.g., tee)
SHELL := /bin/bash -o pipefail

# SystemVerilog source and include directory (use all *.sv files here in design)
SRCDIR := .

# output directory
OUTDIR := out

# Name of the "top" module for design (in ".sv" file with same name)
TOP := gpiotest_main

# Basename of synthesis output files
OUTNAME := gpiotest

# Name of the "top" module for simulation test bed (in ".sv" file with same name)
TBTOP := gpiotest_tb

# Name of C++ top simulation module (for Verilator)
VTOP := gpiotest_main

# Name of simulation output file
TBOUTNAME := gpiotest_tb

# pin definitions file
PIN_DEF := gpiotest.lpf

# FPGA device type
DEVICE := 25k

# FPGA package
PACKAGE := CABGA256

# Verilog source directories
VPATH := $(SRCDIR)

# Verilog source files for design (with TOP module first and no TBTOP)
SRC := $(SRCDIR)/$(TOP).sv $(filter-out $(SRCDIR)/$(TBTOP).sv,$(filter-out $(SRCDIR)/$(TOP).sv,$(wildcard $(SRCDIR)/*.sv)))

# Verilog include files for design
INC := $(wildcard $(SRCDIR)/*.svh)

# tool binaries assumed in default path (e.g. oss-cad-suite with:
# source <extracted_location>/oss-cad-suite/environment"
YOSYS := yosys
YOSYS_CONFIG := yosys-config

# Yosys synthesis options
# ("ultraplus" device, enable DSP inferrence and explicitly set top module name)
YOSYS_SYNTH_OPTS := -device u -dsp -top $(TOP)
# NOTE: Options that can often produce a more "optimal" size/speed for design, but slower:
#       YOSYS_SYNTH_ARGS := -device u -dsp -abc9 -top $(TOP)

# nextpnr ecp5 tool
NEXTPNR := nextpnr-ecp5
# nextpnr-ecp5 options
# (use "heap" placer)
NEXTPNR_ARGS := --placer heap --speed 6
# NOTE: Options that can often produce a more "optimal" size/speed for design, but slower:
#       NEXTPNR_ARGS := --promote-logic --opt-timing --placer heap

# log output directory for tools (spammy, but useful detailed info)
LOGS := logs

# SystemVerilog preprocessor definitions common to all modules (this prevents spurious warnings in TECH_LIB files)
DEFINES := -DNO_ECP5_DEFAULT_ASSIGNMENTS
# uncomment if OSC jumper shorted (will skip gpio_20 test)
DEFINES += -DOSC

# show info on make targets
info:
	@echo "make targets:"
	@echo "    make bin        - synthesize bitstream for design"
	@echo "    make count      - show design resource usage counts"
	@echo "    make clean      - clean most files that can be rebuilt"

# defult target is to make FPGA bitstream for design
all: isim bin

# synthesize FPGA bitstream for design
bin: $(OUTDIR)/$(OUTNAME).bin
	@echo === Synthesizing done ===

# run Yosys with "noflatten", which will produce a resource count per module
count: $(SRC) $(INC) $(FONTFILES) $(MAKEFILE_LIST)
	@echo === Couting Design Resources Used ===
	@mkdir -p $(LOGS)
	$(YOSYS) -l $(LOGS)/$(OUTNAME)_yosys_count.log -w ".*" -q -p 'verilog_defines $(DEFINES) ; read_verilog -I$(SRCDIR) -sv $(SRC) $(FLOW3) ; synth_ecp5 $(YOSYS_SYNTH_ARGS) -noflatten'
	@sed -n '/Printing statistics/,/Executing CHECK pass/p' $(LOGS)/$(OUTNAME)_yosys_count.log | sed '$$d'
	@echo === See $(LOGS)/$(OUTNAME)_yosys_count.log for resource use details ===

# synthesize SystemVerilog and create json description
$(OUTDIR)/$(OUTNAME).json: $(SRC) $(INC) $(MAKEFILE_LIST)
	@echo === Synthesizing design ===
	@rm -f $@
	@mkdir -p $(OUTDIR)
	@mkdir -p $(LOGS)
	$(YOSYS) -l $(LOGS)/$(OUTNAME)_yosys.log -w ".*" -q -p 'verilog_defines $(DEFINES) ; read_verilog -I$(SRCDIR) -sv $(SRC) $(FLOW3) ; synth_ecp5 $(YOSYS_SYNTH_ARGS) -json $@'

# make ASCII bitstream from JSON description and device parameters
$(OUTDIR)/$(OUTNAME)_out.config: $(OUTDIR)/$(OUTNAME).json $(PIN_DEF) $(MAKEFILE_LIST)
	@rm -f $@
	@mkdir -p $(LOGS)
	@mkdir -p $(OUTDIR)
	$(NEXTPNR) -l $(LOGS)/$(OUTNAME)_nextpnr.log -q $(NEXTPNR_ARGS) --$(DEVICE) --package $(PACKAGE) --json $< --lpf $(PIN_DEF) --textcfg $@
	@echo === Synthesis stats for $(OUTNAME) on $(DEVICE) === | tee $(LOGS)/$(OUTNAME)_stats.txt
	@-tabbyadm version | grep "Package" | tee -a $(LOGS)/$(OUTNAME)_stats.txt
	@$(YOSYS) -V 2>&1 | tee -a $(LOGS)/$(OUTNAME)_stats.txt
	@$(NEXTPNR) -V 2>&1 | tee -a $(LOGS)/$(OUTNAME)_stats.txt
	@sed -n '/Device utilisation/,/Info: Placed/p' $(LOGS)/$(OUTNAME)_nextpnr.log | sed '$$d' | grep -v ":     0/" | tee -a $(LOGS)/$(OUTNAME)_stats.txt
	@grep "Max frequency" $(LOGS)/$(OUTNAME)_nextpnr.log | tail -1 | tee -a $(LOGS)/$(OUTNAME)_stats.txt
	@echo

# make binary bitstream from ASCII
$(OUTDIR)/$(OUTNAME).bin: $(OUTDIR)/$(OUTNAME)_out.config
	ecppack $< $@

# delete all targets that will be re-generated
clean:
	rm -f $(OUTDIR)/$(OUTNAME).bin $(OUTDIR)/$(OUTNAME).json $(OUTDIR)/$(OUTNAME)_out.config $(OUTDIR)/$(TBOUTNAME) $(wildcard obj_dir/*)

# prevent make from deleting any intermediate files
.SECONDARY:

# inform make about "phony" convenience targets
.PHONY: info all bin prog lint isim irun count clean

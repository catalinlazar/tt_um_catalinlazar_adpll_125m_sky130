SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM

ifneq ($(GATES),yes)
# --- RTL Simulation Pass ---
SIM_BUILD        = sim_build/rtl

# 1. Load the mock models first so they supply definitions for standard cells
VERILOG_SOURCES += $(PWD)/sky130_mock.v

# 2. Load your design files (Cleaned up the duplicate lines)
VERILOG_SOURCES += $(SRC_DIR)/tt_um_catalinlazar_adpll_125m_sky130.v
VERILOG_SOURCES += $(SRC_DIR)/sync_divider.v

else
# --- Gate-Level (GL) Simulation Pass ---
SIM_BUILD        = sim_build/gl
COMPILE_ARGS     += -DGL_TEST
COMPILE_ARGS     += -DUSE_POWER_PINS

# Note: Tiny Tapeout CI provides PDK paths automatically.
# If testing GL locally, make sure PDK_ROOT is exported in your environment.
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v
endif

# --- Shared Testbench Settings ---
COMPILE_ARGS     += -I$(SRC_DIR)
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb
COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim
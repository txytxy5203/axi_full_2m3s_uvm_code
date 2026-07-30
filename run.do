#-------------------------------------------------------------------------------
# File        : run.do
# Project     : AXI4 Full 2M3S UVM Teaching Project
# Purpose     : Compile, simulate, dump waveforms, and save per-test Questa logs.
# Learn More  : www.bcbaoic.top
#-------------------------------------------------------------------------------

# Leave any previous simulation cleanly before rebuilding work library.
catch {quit -sim}

# Default testcase. You can override it before running this script:
#   set TESTNAME axi_outstanding_read_test
#   do run.do
if {![info exists TESTNAME]} {
    set TESTNAME axi_smoke_single_rw_test
}

# Random seed handling.
# You can override it before running this script:
#   set SEED 123456
#   do run.do
# If SEED is not set, this script creates a timestamp-based seed.
if {![info exists SEED]} {
    set NOW_MS [clock clicks -milliseconds]
    set SEED [expr {$NOW_MS % 2147483647}]
    if {$SEED < 1} {
        set SEED 1
    }
}

# Create log directory first. Use normalized paths so Windows/Questa can locate
# the generated transcript and coverage files reliably.
if {![file exists logs]} {
    file mkdir logs
}

set LOGFILE [file normalize [file join logs ${TESTNAME}_seed_${SEED}.log]]
set CVG_RPT [file normalize [file join logs ${TESTNAME}_seed_${SEED}_functional_coverage.rpt]]
set UCDB_FILE [file normalize [file join logs ${TESTNAME}_seed_${SEED}.ucdb]]

# Important:
# Some Questa GUI sessions keep the transcript file handle open unless the old
# transcript is explicitly closed. Close it first, remove the stale log, then
# reopen a fresh transcript file for this testcase.
# catch {transcript off}

# if {[file exists $LOGFILE]} {
#     file delete -force $LOGFILE
# }

# transcript file $LOGFILE
# transcript on
# echo "DEBUG: transcript file = $LOGFILE"

echo "============================================================"
echo "AXI4 Full 2M3S UVM Teaching Project"
echo "Running TESTNAME = $TESTNAME"
echo "SV random seed = $SEED"
echo "Questa transcript log = $LOGFILE"
echo "Project site = www.bcbaoic.top"
echo "============================================================"

# Rebuild work library.
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile Verilog RTL.
# vlog -work work rtl/axi_2m3s_full_dut.v
vlog -cover bcestf -work work rtl/axi_2m3s_full_dut.v

# Compile SystemVerilog UVM testbench.
# This is intentionally kept as one long line for Windows/Questa compatibility.
# vlog -work work -sv +incdir+$env(MODEL_TECH)/verilog_src/uvm-1.1d/src +incdir+tb +incdir+tb/interfaces +incdir+tb/axi +incdir+tb/env +incdir+tb/seq +incdir+tb/tests tb/interfaces/axi_full_if.sv tb/axi/axi_pkg.sv tb/env/axi_env_pkg.sv tb/seq/axi_seq_pkg.sv tb/tests/axi_test_pkg.sv tb/tb_top.sv
vlog -cover bcestf -work work -sv +incdir+$env(MODEL_TECH)/verilog_src/uvm-1.1d/src +incdir+tb +incdir+tb/interfaces +incdir+tb/axi +incdir+tb/env +incdir+tb/seq +incdir+tb/tests tb/interfaces/axi_full_if.sv tb/axi/axi_pkg.sv tb/env/axi_env_pkg.sv tb/seq/axi_seq_pkg.sv tb/tests/axi_test_pkg.sv tb/tb_top.sv


# Load simulation.
# -voptargs=+acc keeps hierarchy and signals visible for waveform debug.
# -coverage enables UCDB/cvg report generation when your local license supports it.
vsim -coverage -sv_seed $SEED -voptargs=+acc -L mtiUvm work.tb_top +UVM_TESTNAME=$TESTNAME

# add wave -divider "Clock and Reset"
# add wave -radix binary sim:/tb_top/clk
# add wave -radix binary sim:/tb_top/rst_n
# 
# add wave -divider "M0 AXI Write"
# add wave -radix hex      sim:/tb_top/m0_if/awid
# add wave -radix hex      sim:/tb_top/m0_if/awaddr
# add wave -radix unsigned sim:/tb_top/m0_if/awlen
# add wave -radix binary   sim:/tb_top/m0_if/awvalid
# add wave -radix binary   sim:/tb_top/m0_if/awready
# add wave -radix hex      sim:/tb_top/m0_if/wdata
# add wave -radix hex      sim:/tb_top/m0_if/wstrb
# add wave -radix binary   sim:/tb_top/m0_if/wlast
# add wave -radix binary   sim:/tb_top/m0_if/wvalid
# add wave -radix binary   sim:/tb_top/m0_if/wready
# add wave -radix hex      sim:/tb_top/m0_if/bid
# add wave -radix hex      sim:/tb_top/m0_if/bresp
# add wave -radix binary   sim:/tb_top/m0_if/bvalid
# add wave -radix binary   sim:/tb_top/m0_if/bready
# 
# add wave -divider "M0 AXI Read"
# add wave -radix hex      sim:/tb_top/m0_if/arid
# add wave -radix hex      sim:/tb_top/m0_if/araddr
# add wave -radix unsigned sim:/tb_top/m0_if/arlen
# add wave -radix binary   sim:/tb_top/m0_if/arvalid
# add wave -radix binary   sim:/tb_top/m0_if/arready
# add wave -radix hex      sim:/tb_top/m0_if/rid
# add wave -radix hex      sim:/tb_top/m0_if/rdata
# add wave -radix hex      sim:/tb_top/m0_if/rresp
# add wave -radix binary   sim:/tb_top/m0_if/rlast
# add wave -radix binary   sim:/tb_top/m0_if/rvalid
# add wave -radix binary   sim:/tb_top/m0_if/rready
# 
# add wave -divider "M1 AXI Summary"
# add wave -radix hex sim:/tb_top/m1_if/*
# 
# add wave -divider "DUT Internal"
# add wave -radix hex sim:/tb_top/u_dut/*

run -all

# echo "BEFORE FLUSH"

# transcript flush

# echo "AFTER FLUSH"

# Save optional simulator coverage artifacts when supported by the local Questa setup.
# catch {coverage report -cvg -details -file $CVG_RPT}
# catch {coverage save $UCDB_FILE}


echo "============================"
echo "START COVERAGE REPORT"
echo "============================"
coverage report -cvg -details -file $CVG_RPT
echo "============================"
echo "SAVE UCDB"
echo "============================"
coverage save $UCDB_FILE
echo "============================"
echo "COVERAGE DONE"
echo "============================"
quit -sim

echo "============================================================"
echo "Simulation completed for TESTNAME = $TESTNAME"
echo "SV random seed used = $SEED"
echo "Transcript log saved to $LOGFILE"
echo "Functional coverage report saved to $CVG_RPT when available."
echo "UCDB file saved to $UCDB_FILE when available."
echo "============================================================"

# Important: close the transcript so Questa flushes the .log file to disk.
# transcript off

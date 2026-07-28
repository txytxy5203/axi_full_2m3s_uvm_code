/*******************************************************************************
 * File        : axi_env_pkg.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI verification environment package for scoreboard, coverage, and env components.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

package axi_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axi_pkg::*;

    `include "axi_scoreboard.svh"
    `include "axi_coverage.svh"
    `include "axi_virtual_sequencer.svh"
    `include "axi_env.svh"
endpackage

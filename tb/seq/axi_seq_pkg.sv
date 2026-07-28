/*******************************************************************************
 * File        : axi_seq_pkg.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI sequence package for directed and random stimulus generation.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

package axi_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axi_pkg::*;
    import axi_env_pkg::*;

    `include "axi_basic_sequences.svh"
endpackage

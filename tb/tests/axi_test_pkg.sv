/*******************************************************************************
 * File        : axi_test_pkg.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI test package that includes one test class per SystemVerilog file.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

package axi_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import axi_pkg::*;
    import axi_env_pkg::*;
    import axi_seq_pkg::*;

    `include "axi_base_test.sv"
    `include "axi_smoke_single_rw_test.sv"
    `include "axi_all_path_basic_test.sv"
    `include "axi_burst_len_sweep_test.sv"
    `include "axi_burst_data_integrity_test.sv"
    `include "axi_write_strobe_test.sv"
    `include "axi_multi_master_same_slave_test.sv"
    `include "axi_multi_master_diff_slave_test.sv"
    `include "axi_outstanding_write_test.sv"
    `include "axi_outstanding_read_test.sv"
    `include "axi_out_of_order_read_test.sv"
    `include "axi_out_of_order_write_resp_test.sv"
    `include "axi_downstream_backpressure_test.sv"
    `include "axi_master_backpressure_test.sv"
    `include "axi_deadlock_stress_test.sv"
    `include "axi_error_boundary_test.sv"
endpackage

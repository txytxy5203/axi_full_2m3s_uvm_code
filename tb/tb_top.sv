/*******************************************************************************
 * File        : tb_top.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Top-level SystemVerilog testbench for QuestaSim simulation.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import axi_pkg::*;
    import axi_env_pkg::*;
    import axi_seq_pkg::*;
    import axi_test_pkg::*;
    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;
    end

    always begin
        #5ns clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        repeat (10) @(posedge clk);
        rst_n = 1'b1;
    end

    axi_full_if #(32, 32, 4) m0_if(.aclk(clk), .aresetn(rst_n));
    axi_full_if #(32, 32, 4) m1_if(.aclk(clk), .aresetn(rst_n));

    axi_2m3s_full_dut #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ID_WIDTH(4),
        .RD_SLOTS(8),
        .WR_SLOTS(8),
        .MEM_BYTES(4096)
    ) u_dut (
        .aclk(clk),
        .aresetn(rst_n),

        .m0_awid(m0_if.awid),
        .m0_awaddr(m0_if.awaddr),
        .m0_awlen(m0_if.awlen),
        .m0_awsize(m0_if.awsize),
        .m0_awburst(m0_if.awburst),
        .m0_awvalid(m0_if.awvalid),
        .m0_awready(m0_if.awready),
        .m0_wdata(m0_if.wdata),
        .m0_wstrb(m0_if.wstrb),
        .m0_wlast(m0_if.wlast),
        .m0_wvalid(m0_if.wvalid),
        .m0_wready(m0_if.wready),
        .m0_bid(m0_if.bid),
        .m0_bresp(m0_if.bresp),
        .m0_bvalid(m0_if.bvalid),
        .m0_bready(m0_if.bready),
        .m0_arid(m0_if.arid),
        .m0_araddr(m0_if.araddr),
        .m0_arlen(m0_if.arlen),
        .m0_arsize(m0_if.arsize),
        .m0_arburst(m0_if.arburst),
        .m0_arvalid(m0_if.arvalid),
        .m0_arready(m0_if.arready),
        .m0_rid(m0_if.rid),
        .m0_rdata(m0_if.rdata),
        .m0_rresp(m0_if.rresp),
        .m0_rlast(m0_if.rlast),
        .m0_rvalid(m0_if.rvalid),
        .m0_rready(m0_if.rready),

        .m1_awid(m1_if.awid),
        .m1_awaddr(m1_if.awaddr),
        .m1_awlen(m1_if.awlen),
        .m1_awsize(m1_if.awsize),
        .m1_awburst(m1_if.awburst),
        .m1_awvalid(m1_if.awvalid),
        .m1_awready(m1_if.awready),
        .m1_wdata(m1_if.wdata),
        .m1_wstrb(m1_if.wstrb),
        .m1_wlast(m1_if.wlast),
        .m1_wvalid(m1_if.wvalid),
        .m1_wready(m1_if.wready),
        .m1_bid(m1_if.bid),
        .m1_bresp(m1_if.bresp),
        .m1_bvalid(m1_if.bvalid),
        .m1_bready(m1_if.bready),
        .m1_arid(m1_if.arid),
        .m1_araddr(m1_if.araddr),
        .m1_arlen(m1_if.arlen),
        .m1_arsize(m1_if.arsize),
        .m1_arburst(m1_if.arburst),
        .m1_arvalid(m1_if.arvalid),
        .m1_arready(m1_if.arready),
        .m1_rid(m1_if.rid),
        .m1_rdata(m1_if.rdata),
        .m1_rresp(m1_if.rresp),
        .m1_rlast(m1_if.rlast),
        .m1_rvalid(m1_if.rvalid),
        .m1_rready(m1_if.rready)
    );

    initial begin
        uvm_config_db#(virtual axi_full_if #(32, 32, 4))::set(null, "uvm_test_top.env.m0_agent.*", "vif", m0_if);
        uvm_config_db#(virtual axi_full_if #(32, 32, 4))::set(null, "uvm_test_top.env.m1_agent.*", "vif", m1_if);
        run_test();
    end
endmodule

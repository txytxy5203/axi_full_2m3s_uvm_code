/*******************************************************************************
 * File        : axi_full_if.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI4 Full interface bundle used by master agents, monitors, and DUT connections.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

interface axi_full_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 4
)(
    input logic aclk,
    input logic aresetn
);
    logic [ID_WIDTH-1:0]   awid;
    logic [ADDR_WIDTH-1:0] awaddr;
    logic [7:0]            awlen;
    logic [2:0]            awsize;
    logic [1:0]            awburst;
    logic                  awvalid;
    logic                  awready;

    logic [DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                  wlast;
    logic                  wvalid;
    logic                  wready;

    logic [ID_WIDTH-1:0]   bid;
    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;

    logic [ID_WIDTH-1:0]   arid;
    logic [ADDR_WIDTH-1:0] araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;
    logic                  arvalid;
    logic                  arready;

    logic [ID_WIDTH-1:0]   rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rlast;
    logic                  rvalid;
    logic                  rready;

    task automatic init_master_signals();
        awid    = '0;
        awaddr  = '0;
        awlen   = '0;
        awsize  = 3'b010;
        awburst = 2'b01;
        awvalid = 1'b0;
        wdata   = '0;
        wstrb   = '0;
        wlast   = 1'b0;
        wvalid  = 1'b0;
        bready  = 1'b0;
        arid    = '0;
        araddr  = '0;
        arlen   = '0;
        arsize  = 3'b010;
        arburst = 2'b01;
        arvalid = 1'b0;
        rready  = 1'b0;
    endtask

endinterface

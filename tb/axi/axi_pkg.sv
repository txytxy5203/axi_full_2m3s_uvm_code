/*******************************************************************************
 * File        : axi_pkg.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM component package for transaction, driver, monitor, and agent definitions.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

`timescale 1ns/1ps

package axi_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter int AXI_ADDR_WIDTH = 32;
    parameter int AXI_DATA_WIDTH = 32;
    parameter int AXI_ID_WIDTH   = 4;

    typedef enum int {
        AXI_READ  = 0,      
        AXI_WRITE = 1
    } axi_op_e;

    typedef enum int {
        AXI_KIND_REQ       = 0,         // 原始请求
        AXI_KIND_WRITE_CMD = 1,         // 写请求阶段
        AXI_KIND_WRITE_DATA= 2,         // 写数据阶段
        AXI_KIND_WRITE_RSP = 3,         // 写响应阶段
        AXI_KIND_READ_CMD  = 4,         // 读请求阶段
        AXI_KIND_READ_RSP  = 5          // 读响应阶段
    } axi_kind_e;

    localparam bit [1:0] AXI_RESP_OKAY   = 2'b00;
    localparam bit [1:0] AXI_RESP_DECERR = 2'b11;
    localparam bit [1:0] AXI_BURST_INCR  = 2'b01;

    `include "axi_utils.svh"
    `include "axi_item.svh"
    `include "axi_sequencer.svh"
    `include "axi_driver.svh"
    `include "axi_monitor.svh"
    `include "axi_agent.svh"
endpackage

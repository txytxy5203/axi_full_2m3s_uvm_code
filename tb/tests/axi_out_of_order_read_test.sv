/*******************************************************************************
 * File        : axi_out_of_order_read_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_out_of_order_read_test extends axi_outstanding_read_test;
    `uvm_component_utils(axi_out_of_order_read_test)
    function new(string name = "axi_out_of_order_read_test", uvm_component parent = null); super.new(name, parent); endfunction
endclass

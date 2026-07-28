/*******************************************************************************
 * File        : axi_burst_data_integrity_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_burst_data_integrity_test extends axi_burst_len_sweep_test;
    `uvm_component_utils(axi_burst_data_integrity_test)
    function new(string name = "axi_burst_data_integrity_test", uvm_component parent = null); super.new(name, parent); endfunction
endclass

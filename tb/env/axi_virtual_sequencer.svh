/*******************************************************************************
 * File        : axi_virtual_sequencer.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM environment source file for checking, coverage, and verification closure.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(axi_virtual_sequencer)

    axi_master_sequencer m0_seqr;
    axi_master_sequencer m1_seqr;

    function new(string name = "axi_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

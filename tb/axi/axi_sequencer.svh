/*******************************************************************************
 * File        : axi_sequencer.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM agent source file used by the reusable master-side verification component.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_master_sequencer extends uvm_sequencer #(axi_txn);
    `uvm_component_utils(axi_master_sequencer)

    function new(string name = "axi_master_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

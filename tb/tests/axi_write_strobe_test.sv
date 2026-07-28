/*******************************************************************************
 * File        : axi_write_strobe_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_write_strobe_test extends axi_base_test;
    `uvm_component_utils(axi_write_strobe_test)
    function new(string name = "axi_write_strobe_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual task run_phase(uvm_phase phase);
        axi_write_strobe_seq seq;
        phase.raise_objection(this);
        seq = axi_write_strobe_seq::type_id::create("seq");
        seq.start(env.m0_agent.seqr);
        wait_for_drain(400);
        phase.drop_objection(this);
    endtask
endclass

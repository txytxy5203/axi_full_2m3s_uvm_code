/*******************************************************************************
 * File        : axi_smoke_single_rw_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_smoke_single_rw_test extends axi_base_test;
    `uvm_component_utils(axi_smoke_single_rw_test)
    function new(string name = "axi_smoke_single_rw_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual task run_phase(uvm_phase phase);
        axi_single_rw_seq seq;
        phase.raise_objection(this);
        seq = axi_single_rw_seq::type_id::create("seq");
        seq.addr = 32'h0000_0000;
        seq.id = 4'h1;
        seq.burst_len = 1;
        seq.data_base = 32'hCAFE_1000;
        seq.start(env.m0_agent.seqr);
        wait_for_drain(300);
        phase.drop_objection(this);
    endtask
endclass

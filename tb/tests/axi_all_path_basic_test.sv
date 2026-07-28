/*******************************************************************************
 * File        : axi_all_path_basic_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_all_path_basic_test extends axi_base_test;
    `uvm_component_utils(axi_all_path_basic_test)
    function new(string name = "axi_all_path_basic_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual task run_phase(uvm_phase phase);
        axi_all_path_seq s0, s1;
        phase.raise_objection(this);
        s0 = axi_all_path_seq::type_id::create("s0");
        s1 = axi_all_path_seq::type_id::create("s1");
        fork
            s0.start(env.m0_agent.seqr);
            s1.start(env.m1_agent.seqr);
        join
        wait_for_drain(400);
        phase.drop_objection(this);
    endtask
endclass

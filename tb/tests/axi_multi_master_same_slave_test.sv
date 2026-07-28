/*******************************************************************************
 * File        : axi_multi_master_same_slave_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_multi_master_same_slave_test extends axi_base_test;
    `uvm_component_utils(axi_multi_master_same_slave_test)
    function new(string name = "axi_multi_master_same_slave_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual task run_phase(uvm_phase phase);
        axi_single_rw_seq m0, m1;
        phase.raise_objection(this);
        m0 = axi_single_rw_seq::type_id::create("m0");
        m1 = axi_single_rw_seq::type_id::create("m1");
        m0.addr = 32'h0000_0300; m0.id = 4'h1; m0.burst_len = 4; m0.data_base = 32'hA000_0000;
        m1.addr = 32'h0000_0400; m1.id = 4'h2; m1.burst_len = 4; m1.data_base = 32'hB000_0000;
        fork
            m0.start(env.m0_agent.seqr);
            m1.start(env.m1_agent.seqr);
        join
        wait_for_drain(500);
        phase.drop_objection(this);
    endtask
endclass

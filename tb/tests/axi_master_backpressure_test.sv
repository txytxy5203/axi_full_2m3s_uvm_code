/*******************************************************************************
 * File        : axi_master_backpressure_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_master_backpressure_test extends axi_base_test;
    `uvm_component_utils(axi_master_backpressure_test)
    function new(string name = "axi_master_backpressure_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual function void build_phase(uvm_phase phase);
        uvm_config_db#(int)::set(this, "env.m0_agent.drv", "bready_delay_max", 3);
        uvm_config_db#(int)::set(this, "env.m0_agent.drv", "rready_delay_max", 3);
        uvm_config_db#(int)::set(this, "env.m1_agent.drv", "bready_delay_max", 3);
        uvm_config_db#(int)::set(this, "env.m1_agent.drv", "rready_delay_max", 3);
        super.build_phase(phase);
    endfunction
    virtual task run_phase(uvm_phase phase);
        axi_random_stress_seq m0, m1;
        phase.raise_objection(this);
        m0 = axi_random_stress_seq::type_id::create("m0");
        m1 = axi_random_stress_seq::type_id::create("m1");
        m0.num_txn = 10; m1.num_txn = 10;
        fork
            m0.start(env.m0_agent.seqr);
            m1.start(env.m1_agent.seqr);
        join
        wait_for_drain(1500);
        phase.drop_objection(this);
    endtask
endclass

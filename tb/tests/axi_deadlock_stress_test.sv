/*******************************************************************************
 * File        : axi_deadlock_stress_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Single UVM testcase file for one AXI4 Full verification scenario.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_deadlock_stress_test extends axi_master_backpressure_test;
    `uvm_component_utils(axi_deadlock_stress_test)
    function new(string name = "axi_deadlock_stress_test", uvm_component parent = null); super.new(name, parent); endfunction
    virtual task run_phase(uvm_phase phase);
        axi_random_stress_seq m0, m1;
        phase.raise_objection(this);
        m0 = axi_random_stress_seq::type_id::create("m0");
        m1 = axi_random_stress_seq::type_id::create("m1");
        m0.num_txn = 25; m1.num_txn = 25;
        fork
            m0.start(env.m0_agent.seqr);
            m1.start(env.m1_agent.seqr);
            begin
                #20000ns;
                `uvm_error("DEADLOCK", "Watchdog timeout: test did not finish in expected time")
            end
        join_any
        disable fork;
        wait_for_drain(2000);
        phase.drop_objection(this);
    endtask
endclass

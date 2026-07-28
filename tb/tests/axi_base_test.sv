/*******************************************************************************
 * File        : axi_base_test.sv
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : Base UVM test providing common environment construction and drain timing.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    axi_env env;

    function new(string name = "axi_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    endfunction

    task wait_for_drain(int unsigned cycles = 200);
        #(cycles * 10ns);
    endtask
endclass

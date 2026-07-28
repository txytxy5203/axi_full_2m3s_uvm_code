/*******************************************************************************
 * File        : axi_agent.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM agent source file used by the reusable master-side verification component.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_master_agent extends uvm_agent;
    `uvm_component_utils(axi_master_agent)

    axi_master_sequencer seqr;
    axi_master_driver    drv;
    axi_master_monitor   mon;
    int master_id;

    function new(string name = "axi_master_agent", uvm_component parent = null);
        super.new(name, parent);
        master_id = 0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db#(int)::get(this, "", "master_id", master_id));
        mon = axi_master_monitor::type_id::create("mon", this);
        uvm_config_db#(int)::set(this, "mon", "master_id", master_id);
        if (is_active == UVM_ACTIVE) begin
            seqr = axi_master_sequencer::type_id::create("seqr", this);
            drv  = axi_master_driver::type_id::create("drv", this);
            uvm_config_db#(int)::set(this, "drv", "master_id", master_id);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass

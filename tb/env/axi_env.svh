/*******************************************************************************
 * File        : axi_env.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM environment source file for checking, coverage, and verification closure.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_master_agent      m0_agent;
    axi_master_agent      m1_agent;
    axi_virtual_sequencer vseqr;
    axi_scoreboard        scb;
    axi_coverage          cov;

    function new(string name = "axi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m0_agent = axi_master_agent::type_id::create("m0_agent", this);
        m1_agent = axi_master_agent::type_id::create("m1_agent", this);
        vseqr    = axi_virtual_sequencer::type_id::create("vseqr", this);
        scb      = axi_scoreboard::type_id::create("scb", this);
        cov      = axi_coverage::type_id::create("cov", this);

        uvm_config_db#(uvm_active_passive_enum)::set(this, "m0_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "m1_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(int)::set(this, "m0_agent", "master_id", 0);
        uvm_config_db#(int)::set(this, "m1_agent", "master_id", 1);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vseqr.m0_seqr = m0_agent.seqr;
        vseqr.m1_seqr = m1_agent.seqr;
        m0_agent.mon.ap.connect(scb.m0_fifo.analysis_export);
        m1_agent.mon.ap.connect(scb.m1_fifo.analysis_export);
        m0_agent.mon.ap.connect(cov.analysis_export);
        m1_agent.mon.ap.connect(cov.analysis_export);
    endfunction
endclass

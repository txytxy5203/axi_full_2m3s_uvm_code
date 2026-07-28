/*******************************************************************************
 * File        : axi_driver.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM agent source file used by the reusable master-side verification component.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_master_driver extends uvm_driver #(axi_txn);
    `uvm_component_utils(axi_master_driver)

    virtual axi_full_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH) vif;
    int master_id;
    int bready_delay_max;
    int rready_delay_max;

    function new(string name = "axi_master_driver", uvm_component parent = null);
        super.new(name, parent);
        master_id = 0;
        bready_delay_max = 0;
        rready_delay_max = 0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_full_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("%s cannot get virtual interface", get_full_name()))
        end
        void'(uvm_config_db#(int)::get(this, "", "master_id", master_id));
        void'(uvm_config_db#(int)::get(this, "", "bready_delay_max", bready_delay_max));
        void'(uvm_config_db#(int)::get(this, "", "rready_delay_max", rready_delay_max));
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.init_master_signals();
        wait(vif.aresetn === 1'b1);
        @(posedge vif.aclk);
        fork
            drive_response_ready();
            drive_items();
        join
    endtask

    task drive_items();
        axi_txn tr;
        forever begin
            seq_item_port.get_next_item(tr);
            tr.master_id = master_id;
            if (tr.op == AXI_WRITE) begin
                drive_write(tr);
            end else begin
                drive_read(tr);
            end
            seq_item_port.item_done();
        end
    endtask

    task drive_response_ready();
        forever begin
            @(posedge vif.aclk);
            if (!vif.aresetn) begin
                vif.bready <= 1'b0;
                vif.rready <= 1'b0;
            end else begin
                if (bready_delay_max <= 0)
                    vif.bready <= 1'b1;
                else
                    vif.bready <= ($urandom_range(0, bready_delay_max) != 0);

                if (rready_delay_max <= 0)
                    vif.rready <= 1'b1;
                else
                    vif.rready <= ($urandom_range(0, rready_delay_max) != 0);
            end
        end
    endtask

    task drive_write(axi_txn tr);
        int beat;
        if (tr.data.size() != tr.burst_len) begin
            `uvm_fatal("BAD_TXN", $sformatf("write data size %0d does not match burst_len %0d", tr.data.size(), tr.burst_len))
        end
        if (tr.strb.size() != tr.burst_len) begin
            `uvm_fatal("BAD_TXN", $sformatf("write strb size %0d does not match burst_len %0d", tr.strb.size(), tr.burst_len))
        end

        `uvm_info("AXI_DRV", $sformatf("M%0d drive WRITE %s", master_id, tr.convert2string()), UVM_MEDIUM)

        @(posedge vif.aclk);
        vif.awid    <= tr.id;
        vif.awaddr  <= tr.addr;
        vif.awlen   <= tr.burst_len - 1;
        vif.awsize  <= 3'b010;
        vif.awburst <= AXI_BURST_INCR;
        vif.awvalid <= 1'b1;
        do begin
            @(posedge vif.aclk);
        end while (!vif.awready);
        vif.awvalid <= 1'b0;

        for (beat = 0; beat < tr.burst_len; beat++) begin
            vif.wdata  <= tr.data[beat];
            vif.wstrb  <= tr.strb[beat];
            vif.wlast  <= (beat == tr.burst_len - 1);
            vif.wvalid <= 1'b1;
            do begin
                @(posedge vif.aclk);
            end while (!vif.wready);
        end
        vif.wvalid <= 1'b0;
        vif.wlast  <= 1'b0;
        vif.wdata  <= '0;
        vif.wstrb  <= '0;
    endtask

    task drive_read(axi_txn tr);
        `uvm_info("AXI_DRV", $sformatf("M%0d drive READ %s", master_id, tr.convert2string()), UVM_MEDIUM)
        @(posedge vif.aclk);
        vif.arid    <= tr.id;
        vif.araddr  <= tr.addr;
        vif.arlen   <= tr.burst_len - 1;
        vif.arsize  <= 3'b010;
        vif.arburst <= AXI_BURST_INCR;
        vif.arvalid <= 1'b1;
        do begin
            @(posedge vif.aclk);
        end while (!vif.arready);
        vif.arvalid <= 1'b0;
    endtask
endclass

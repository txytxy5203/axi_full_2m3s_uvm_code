/*******************************************************************************
 * File        : axi_monitor.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM agent source file used by the reusable master-side verification component.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_write_ctx;
    bit [AXI_ID_WIDTH-1:0] id;
    bit [AXI_ADDR_WIDTH-1:0] addr;
    int unsigned burst_len;
    bit [AXI_DATA_WIDTH-1:0] data[$];
    bit [(AXI_DATA_WIDTH/8)-1:0] strb[$];
endclass

class axi_read_ctx;
    bit [AXI_ID_WIDTH-1:0] id;
    bit [AXI_ADDR_WIDTH-1:0] addr;
    int unsigned burst_len;
    bit [AXI_DATA_WIDTH-1:0] data[$];
    bit [1:0] resp;
endclass

class axi_master_monitor extends uvm_component;
    `uvm_component_utils(axi_master_monitor)

    virtual axi_full_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH) vif;
    uvm_analysis_port #(axi_txn) ap;
    int master_id;

    axi_write_ctx aw_q[$];
    axi_write_ctx cur_w;
    bit has_cur_w;

    axi_read_ctx ar_q[$];
    axi_read_ctx cur_r;
    bit has_cur_r;

    function new(string name = "axi_master_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        master_id = 0;
        has_cur_w = 0;
        has_cur_r = 0;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_full_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", $sformatf("%s cannot get virtual interface", get_full_name()))
        end
        void'(uvm_config_db#(int)::get(this, "", "master_id", master_id));
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait(vif.aresetn === 1'b1);
        forever begin
            @(posedge vif.aclk);
            if (!vif.aresetn) begin
                aw_q.delete();
                ar_q.delete();
                has_cur_w = 0;
                has_cur_r = 0;
            end else begin
                sample_aw();
                sample_w();
                sample_b();
                sample_ar();
                sample_r();
            end
        end
    endtask

    function void sample_aw();
        axi_write_ctx ctx;
        axi_txn tx;
        if (vif.awvalid && vif.awready) begin
            ctx = new();
            ctx.id = vif.awid;
            ctx.addr = vif.awaddr;
            ctx.burst_len = int'(vif.awlen) + 1;
            aw_q.push_back(ctx);

            tx = axi_txn::type_id::create("mon_write_cmd");
            tx.kind = AXI_KIND_WRITE_CMD;
            tx.op = AXI_WRITE;
            tx.master_id = master_id;
            tx.id = vif.awid;
            tx.addr = vif.awaddr;
            tx.burst_len = int'(vif.awlen) + 1;
            tx.slave_id = axi_decode_slave(vif.awaddr);
            tx.resp = axi_legal_burst(vif.awaddr, tx.burst_len) ? AXI_RESP_OKAY : AXI_RESP_DECERR;
            ap.write(tx);
        end
    endfunction

    function void sample_w();
        axi_txn tx;
        if (vif.wvalid && vif.wready) begin
            if (!has_cur_w) begin
                if (aw_q.size() == 0) begin
                    `uvm_error("AXI_MON", $sformatf("M%0d W beat seen before AW", master_id))
                    return;
                end
                cur_w = aw_q.pop_front();
                has_cur_w = 1;
            end
            cur_w.data.push_back(vif.wdata);
            cur_w.strb.push_back(vif.wstrb);
            if (vif.wlast) begin
                tx = axi_txn::type_id::create("mon_write_data");
                tx.kind = AXI_KIND_WRITE_DATA;
                tx.op = AXI_WRITE;
                tx.master_id = master_id;
                tx.id = cur_w.id;
                tx.addr = cur_w.addr;
                tx.burst_len = cur_w.burst_len;
                tx.slave_id = axi_decode_slave(cur_w.addr);
                tx.resp = axi_legal_burst(cur_w.addr, cur_w.burst_len) ? AXI_RESP_OKAY : AXI_RESP_DECERR;
                tx.data = new[cur_w.data.size()];
                tx.strb = new[cur_w.strb.size()];
                foreach (cur_w.data[i]) tx.data[i] = cur_w.data[i];
                foreach (cur_w.strb[i]) tx.strb[i] = cur_w.strb[i];
                ap.write(tx);
                has_cur_w = 0;
            end
        end
    endfunction

    function void sample_b();
        axi_txn tx;
        if (vif.bvalid && vif.bready) begin
            tx = axi_txn::type_id::create("mon_write_rsp");
            tx.kind = AXI_KIND_WRITE_RSP;
            tx.op = AXI_WRITE;
            tx.master_id = master_id;
            tx.id = vif.bid;
            tx.resp = vif.bresp;
            ap.write(tx);
        end
    endfunction

    function void sample_ar();
        axi_read_ctx ctx;
        axi_txn tx;
        if (vif.arvalid && vif.arready) begin
            ctx = new();
            ctx.id = vif.arid;
            ctx.addr = vif.araddr;
            ctx.burst_len = int'(vif.arlen) + 1;
            ctx.resp = axi_legal_burst(vif.araddr, ctx.burst_len) ? AXI_RESP_OKAY : AXI_RESP_DECERR;
            ar_q.push_back(ctx);

            tx = axi_txn::type_id::create("mon_read_cmd");
            tx.kind = AXI_KIND_READ_CMD;
            tx.op = AXI_READ;
            tx.master_id = master_id;
            tx.id = vif.arid;
            tx.addr = vif.araddr;
            tx.burst_len = int'(vif.arlen) + 1;
            tx.slave_id = axi_decode_slave(vif.araddr);
            tx.resp = ctx.resp;
            ap.write(tx);
        end
    endfunction

    function int find_ar_by_id(bit [AXI_ID_WIDTH-1:0] id);
        foreach (ar_q[i]) begin
            if (ar_q[i].id == id) return i;
        end
        return -1;
    endfunction

    function void sample_r();
        axi_txn tx;
        int idx;
        if (vif.rvalid && vif.rready) begin
            if (!has_cur_r) begin
                idx = find_ar_by_id(vif.rid);
                if (idx < 0) begin
                    `uvm_error("AXI_MON", $sformatf("M%0d R beat with unknown RID 0x%0h", master_id, vif.rid))
                    return;
                end
                cur_r = ar_q[idx];
                ar_q.delete(idx);
                has_cur_r = 1;
            end
            cur_r.data.push_back(vif.rdata);
            cur_r.resp = vif.rresp;
            if (vif.rlast) begin
                tx = axi_txn::type_id::create("mon_read_rsp");
                tx.kind = AXI_KIND_READ_RSP;
                tx.op = AXI_READ;
                tx.master_id = master_id;
                tx.id = cur_r.id;
                tx.addr = cur_r.addr;
                tx.burst_len = cur_r.burst_len;
                tx.slave_id = axi_decode_slave(cur_r.addr);
                tx.resp = cur_r.resp;
                tx.data = new[cur_r.data.size()];
                foreach (cur_r.data[i]) tx.data[i] = cur_r.data[i];
                ap.write(tx);
                has_cur_r = 0;
            end
        end
    endfunction
endclass

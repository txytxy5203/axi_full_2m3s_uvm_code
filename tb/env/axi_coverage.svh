/*******************************************************************************
 * File        : axi_coverage.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM environment source file for checking, coverage, and verification closure.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_coverage extends uvm_subscriber #(axi_txn);
    `uvm_component_utils(axi_coverage)

    int cg_master_id;
    int cg_op;
    int cg_slave_id;
    int cg_burst_len;
    int cg_resp;
    int cg_ooo;
    int cg_depth;
    int cg_kind;

    bit [AXI_ID_WIDTH-1:0] rd_order_q[2][$];
    bit [AXI_ID_WIDTH-1:0] wr_order_q[2][$];
    int rd_outstanding[2];
    int wr_outstanding[2];

    covergroup axi_cg;
        option.per_instance = 1;

        cp_master: coverpoint cg_master_id {
            bins m0 = {0};
            bins m1 = {1};
        }

        cp_op: coverpoint cg_op {
            bins read  = {AXI_READ};
            bins write = {AXI_WRITE};
        }

        cp_slave: coverpoint cg_slave_id {
            bins s0 = {0};
            bins s1 = {1};
            bins s2 = {2};
            bins invalid = {3};
        }

        cp_len: coverpoint cg_burst_len {
            bins len1  = {1};
            bins len2  = {2};
            bins len4  = {4};
            bins len8  = {8};
            bins len16 = {16};
        }

        cp_resp: coverpoint cg_resp {
            bins okay   = {AXI_RESP_OKAY};
            bins decerr = {AXI_RESP_DECERR};
        }

        cp_ooo: coverpoint cg_ooo {
            bins in_order = {0};
            bins out_of_order = {1};
        }

        cp_depth: coverpoint cg_depth {
            bins d0 = {0};
            bins d1 = {1};
            bins d2 = {2};
            bins d3_4 = {[3:4]};
            bins d5_plus = {[5:16]};
        }

        cross_master_slave_op: cross cp_master, cp_slave, cp_op;
        cross_len_op:          cross cp_len, cp_op;
        cross_resp_op:         cross cp_resp, cp_op;
        cross_depth_op:        cross cp_depth, cp_op;
        cross_ooo_op:          cross cp_ooo, cp_op;
    endgroup

    function new(string name = "axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        axi_cg = new();
        rd_outstanding[0] = 0; rd_outstanding[1] = 0;
        wr_outstanding[0] = 0; wr_outstanding[1] = 0;
    endfunction

    virtual function void write(axi_txn t);
        axi_txn tx;
        tx = axi_txn::type_id::create("cov_tx");
        tx.copy(t);
        update_order_and_depth(tx);

        cg_master_id = tx.master_id;
        cg_op        = tx.op;
        cg_slave_id  = (tx.slave_id >= 0) ? tx.slave_id : axi_decode_slave(tx.addr);
        cg_burst_len = tx.burst_len;
        cg_resp      = tx.resp;
        cg_ooo       = tx.out_of_order;
        cg_depth     = tx.outstanding_depth;
        cg_kind      = tx.kind;
        axi_cg.sample();
    endfunction

    function void update_order_and_depth(axi_txn tx);
        int mid;
        int idx;
        mid = (tx.master_id < 0 || tx.master_id > 1) ? 0 : tx.master_id;
        tx.out_of_order = 0;
        tx.outstanding_depth = 0;

        case (tx.kind)
            AXI_KIND_READ_CMD: begin
                rd_order_q[mid].push_back(tx.id);
                rd_outstanding[mid]++;
                tx.outstanding_depth = rd_outstanding[mid];
            end
            AXI_KIND_READ_RSP: begin
                tx.outstanding_depth = rd_outstanding[mid];
                if (rd_order_q[mid].size() > 0 && rd_order_q[mid][0] != tx.id)
                    tx.out_of_order = 1;
                idx = -1;
                for (int i = 0; i < rd_order_q[mid].size(); i++) begin
                    if (rd_order_q[mid][i] == tx.id && idx < 0) idx = i;
                end
                if (idx >= 0) rd_order_q[mid].delete(idx);
                if (rd_outstanding[mid] > 0) rd_outstanding[mid]--;
            end
            AXI_KIND_WRITE_CMD: begin
                wr_order_q[mid].push_back(tx.id);
                wr_outstanding[mid]++;
                tx.outstanding_depth = wr_outstanding[mid];
            end
            AXI_KIND_WRITE_RSP: begin
                tx.outstanding_depth = wr_outstanding[mid];
                if (wr_order_q[mid].size() > 0 && wr_order_q[mid][0] != tx.id)
                    tx.out_of_order = 1;
                idx = -1;
                for (int i = 0; i < wr_order_q[mid].size(); i++) begin
                    if (wr_order_q[mid][i] == tx.id && idx < 0) idx = i;
                end
                if (idx >= 0) wr_order_q[mid].delete(idx);
                if (wr_outstanding[mid] > 0) wr_outstanding[mid]--;
            end
            default: begin end
        endcase
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AXI_COV", $sformatf("Functional coverage = %.2f%%", axi_cg.get_coverage()), UVM_NONE)
    endfunction
endclass

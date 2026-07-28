/*******************************************************************************
 * File        : axi_scoreboard.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM environment source file for checking, coverage, and verification closure.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_scoreboard extends uvm_component;
    `uvm_component_utils(axi_scoreboard)

    uvm_tlm_analysis_fifo #(axi_txn) m0_fifo;
    uvm_tlm_analysis_fifo #(axi_txn) m1_fifo;

    bit [7:0] ref_mem [longint unsigned];
    int unsigned pass_count;
    int unsigned fail_count;
    int unsigned write_count;
    int unsigned read_count;

    function new(string name = "axi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        m0_fifo = new("m0_fifo", this);
        m1_fifo = new("m1_fifo", this);
        pass_count = 0;
        fail_count = 0;
        write_count = 0;
        read_count = 0;
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            consume_fifo(m0_fifo, 0);
            consume_fifo(m1_fifo, 1);
        join
    endtask

    task consume_fifo(uvm_tlm_analysis_fifo #(axi_txn) fifo, int mid);
        axi_txn tx;
        forever begin
            fifo.get(tx);
            process_txn(tx);
        end
    endtask

    function bit [7:0] mem_read_byte(longint unsigned addr);
        if (ref_mem.exists(addr)) return ref_mem[addr];
        else return 8'h00;
    endfunction

    function bit [31:0] mem_read_word(bit [31:0] addr);
        return {mem_read_byte(addr+3), mem_read_byte(addr+2), mem_read_byte(addr+1), mem_read_byte(addr+0)};
    endfunction

    function void mem_write_word(bit [31:0] addr, bit [31:0] data, bit [3:0] strb);
        if (strb[0]) ref_mem[addr+0] = data[7:0];
        if (strb[1]) ref_mem[addr+1] = data[15:8];
        if (strb[2]) ref_mem[addr+2] = data[23:16];
        if (strb[3]) ref_mem[addr+3] = data[31:24];
    endfunction

    function void process_txn(axi_txn tx);
        case (tx.kind)
            AXI_KIND_WRITE_DATA: check_and_apply_write(tx);
            AXI_KIND_READ_RSP:   check_read(tx);
            AXI_KIND_WRITE_RSP:  check_write_resp(tx);
            default: begin end
        endcase
    endfunction

    function void check_and_apply_write(axi_txn tx);
        bit legal;
        legal = axi_legal_burst(tx.addr, tx.burst_len);
        if (tx.resp != (legal ? AXI_RESP_OKAY : AXI_RESP_DECERR)) begin
            `uvm_error("AXI_SCB", $sformatf("WRITE_DATA expected resp model mismatch: %s", tx.convert2string()))
            fail_count++;
        end
        if (legal) begin
            if (tx.data.size() != tx.burst_len || tx.strb.size() != tx.burst_len) begin
                `uvm_error("AXI_SCB", $sformatf("WRITE_DATA size mismatch: %s data_size=%0d strb_size=%0d", tx.convert2string(), tx.data.size(), tx.strb.size()))
                fail_count++;
                return;
            end
            for (int i = 0; i < tx.burst_len; i++) begin
                mem_write_word(tx.addr + i*4, tx.data[i], tx.strb[i]);
            end
            write_count++;
            `uvm_info("AXI_SCB", $sformatf("WRITE model updated: %s", tx.convert2string()), UVM_LOW)
        end
    endfunction

    function void check_write_resp(axi_txn tx);
        if (!(tx.resp inside {AXI_RESP_OKAY, AXI_RESP_DECERR})) begin
            `uvm_error("AXI_SCB", $sformatf("Unexpected BRESP: %s", tx.convert2string()))
            fail_count++;
        end else begin
            pass_count++;
        end
    endfunction

    function void check_read(axi_txn tx);
        bit legal;
        bit [31:0] exp;
        legal = axi_legal_burst(tx.addr, tx.burst_len);
        read_count++;

        if (tx.resp != (legal ? AXI_RESP_OKAY : AXI_RESP_DECERR)) begin
            `uvm_error("AXI_SCB", $sformatf("READ resp mismatch legal=%0d: %s", legal, tx.convert2string()))
            fail_count++;
            return;
        end

        if (!legal) begin
            pass_count++;
            return;
        end

        if (tx.data.size() != tx.burst_len) begin
            `uvm_error("AXI_SCB", $sformatf("READ data size mismatch: %s data_size=%0d", tx.convert2string(), tx.data.size()))
            fail_count++;
            return;
        end

        for (int i = 0; i < tx.burst_len; i++) begin
            exp = mem_read_word(tx.addr + i*4);
            if (tx.data[i] !== exp) begin
                `uvm_error("AXI_SCB", $sformatf("READ data mismatch mid=%0d id=0x%0h addr=0x%08h beat=%0d exp=0x%08h got=0x%08h",
                           tx.master_id, tx.id, tx.addr, i, exp, tx.data[i]))
                fail_count++;
            end else begin
                pass_count++;
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AXI_SCB", $sformatf("Scoreboard summary: pass=%0d fail=%0d writes=%0d reads=%0d", pass_count, fail_count, write_count, read_count), UVM_NONE)
        if (fail_count != 0) begin
            `uvm_error("AXI_SCB", $sformatf("Scoreboard found %0d failures", fail_count))
        end
    endfunction
endclass

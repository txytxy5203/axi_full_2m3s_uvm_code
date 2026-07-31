/*******************************************************************************
 * File        : axi_basic_sequences.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI sequence source file for generating teaching-oriented stimulus scenarios.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

class axi_master_base_seq extends uvm_sequence #(axi_txn);
    `uvm_object_utils(axi_master_base_seq)

    function new(string name = "axi_master_base_seq");
        super.new(name);
    endfunction

    // 读和写最重要的区别：

    // 写	读
    // sequence 提供 data[]	sequence 不需要提供数据
    // sequence 提供 strb[]	sequence 不需要提供 strb
    // Driver 驱动 AW + W 通道	Driver 只驱动 AR 通道
    // 数据从 Master 流向 DUT	数据从 DUT 流向 Master


    task send_write(bit [31:0] addr, bit [3:0] id, int unsigned burst_len, 
                    bit [31:0] base_data, bit [3:0] strobe = 4'hF);
                    // strobe 默认全选通
        axi_txn tx;
        tx = axi_txn::type_id::create("wr_tx");         // 通过UVM工厂创建
        start_item(tx);         // 向 sequencer 请求发送权限（如果多个 sequence 同时在跑，可能需要等待） 等待 driver 准备好接收新的 item
        tx.op = AXI_WRITE;
        tx.kind = AXI_KIND_REQ;
        tx.id = id;
        tx.addr = addr;
        tx.alloc_arrays(burst_len);         // 分配 data 和 strb 数组
        for (int i = 0; i < burst_len; i++) begin
            tx.data[i] = base_data + i;
            tx.strb[i] = strobe;
        end
        finish_item(tx);        // 向 sequencer 发送 item 完成，driver 可以接收并处理
    endtask

    task send_read(bit [31:0] addr, bit [3:0] id, int unsigned burst_len);
        axi_txn tx;
        tx = axi_txn::type_id::create("rd_tx");
        start_item(tx);
        tx.op = AXI_READ;
        tx.kind = AXI_KIND_REQ;
        tx.id = id;
        tx.addr = addr;
        tx.alloc_arrays(burst_len);
        // ★ 注意！读不需要设置 data 和 strb
        // 因为读是 DUT → Master，数据是 DUT 返回的
        // sequence 不需要提供数据
        finish_item(tx);
    endtask
endclass

class axi_single_rw_seq extends axi_master_base_seq;
    // 这个seq相当于一次操作流程
    `uvm_object_utils(axi_single_rw_seq)

    bit [31:0] addr;
    bit [3:0]  id;
    int unsigned burst_len;
    bit [31:0] data_base;
    bit [3:0]  strobe;

    function new(string name = "axi_single_rw_seq");
        super.new(name);
        addr = 32'h0000_0000;
        id = 4'h1;
        burst_len = 1;
        data_base = 32'hA5A5_0000;
        strobe = 4'hF;
    endfunction

    virtual task body();
        send_write(addr, id, burst_len, data_base, strobe);
        #80ns;
        send_read(addr, id, burst_len);
    endtask
endclass

class axi_all_path_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_all_path_seq)

    function new(string name = "axi_all_path_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] bases[3];
        bases[0] = 32'h0000_0000;
        bases[1] = 32'h0001_0000;
        bases[2] = 32'h0002_0000;
        foreach (bases[i]) begin
            send_write(bases[i] + (i*16), (i+1), 2, 32'h1000_0000 + (i*16), 4'hF);
            #40ns;
            send_read (bases[i] + (i*16), (i+1), 2);
            #80ns;
        end
    endtask
endclass

class axi_burst_len_sweep_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_burst_len_sweep_seq)

    bit [31:0] base_addr;
    function new(string name = "axi_burst_len_sweep_seq");
        super.new(name);
        base_addr = 32'h0000_0100;
    endfunction

    virtual task body();
        int lens[5];
        lens[0] = 1; lens[1] = 2; lens[2] = 4; lens[3] = 8; lens[4] = 16;
        foreach (lens[i]) begin
            send_write(base_addr + (i*128), (i+1), lens[i], 32'hB000_0000 + (i*256), 4'hF);
            #80ns;
            send_read (base_addr + (i*128), (i+1), lens[i]);
            #120ns;
        end
    endtask
endclass

class axi_write_strobe_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_write_strobe_seq)

    function new(string name = "axi_write_strobe_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0] a;
        a = 32'h0001_0200;
        send_write(a, 4'h1, 1, 32'hFFFF_FFFF, 4'hF);
        #40ns;
        send_write(a, 4'h2, 1, 32'h0000_00AA, 4'b0001);
        #40ns;
        send_write(a, 4'h3, 1, 32'h0000_BB00, 4'b0010);
        #40ns;
        send_write(a, 4'h4, 1, 32'h00CC_0000, 4'b0100);
        #40ns;
        send_write(a, 4'h5, 1, 32'hDD00_0000, 4'b1000);
        #80ns;
        send_read(a, 4'h6, 1);
    endtask
endclass

class axi_outstanding_read_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_outstanding_read_seq)

    function new(string name = "axi_outstanding_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        // Different slaves produce different response latencies in the teaching RTL.
        send_read(32'h0002_0000, 4'h1, 4); // S2, slower
        send_read(32'h0000_0040, 4'h2, 4); // S0, faster, likely returns first
        send_read(32'h0001_0080, 4'h3, 4); // S1
        send_read(32'h0000_00C0, 4'h4, 4); // S0
    endtask
endclass

class axi_outstanding_write_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_outstanding_write_seq)

    function new(string name = "axi_outstanding_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        send_write(32'h0002_0100, 4'h1, 4, 32'h2000_1000, 4'hF);
        send_write(32'h0000_0200, 4'h2, 4, 32'h2000_2000, 4'hF);
        send_write(32'h0001_0300, 4'h3, 4, 32'h2000_3000, 4'hF);
        send_write(32'h0000_0400, 4'h4, 4, 32'h2000_4000, 4'hF);
        #160ns;
        send_read(32'h0002_0100, 4'h5, 4);
        send_read(32'h0000_0200, 4'h6, 4);
        send_read(32'h0001_0300, 4'h7, 4);
        send_read(32'h0000_0400, 4'h8, 4);
    endtask
endclass

class axi_error_boundary_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_error_boundary_seq)

    function new(string name = "axi_error_boundary_seq");
        super.new(name);
    endfunction

    virtual task body();
        // Invalid address
        send_write(32'h0003_0000, 4'h1, 4, 32'hDEAD_0000, 4'hF);
        send_read (32'h0003_0000, 4'h2, 4);
        // Crosses S0 boundary: start at 0xFFC, len=2 -> second beat outside S0.
        send_write(32'h0000_0FFC, 4'h3, 2, 32'hBAD0_0000, 4'hF);
        send_read (32'h0000_0FFC, 4'h4, 2);
    endtask
endclass

class axi_random_stress_seq extends axi_master_base_seq;
    `uvm_object_utils(axi_random_stress_seq)

    int unsigned num_txn;

    function new(string name = "axi_random_stress_seq");
        super.new(name);
        num_txn = 30;
    endfunction

    virtual task body();
        bit [31:0] bases[3];
        int lens[5];
        int s;
        int lidx;
        bit [31:0] addr;
        bases[0] = 32'h0000_0000;
        bases[1] = 32'h0001_0000;
        bases[2] = 32'h0002_0000;
        lens[0] = 1; lens[1] = 2; lens[2] = 4; lens[3] = 8; lens[4] = 16;
        for (int i = 0; i < num_txn; i++) begin
            s = $urandom_range(0, 2);
            lidx = $urandom_range(0, 4);
            addr = bases[s] + (($urandom_range(0, 64) * 4) & 32'h0000_0F00);
            if ($urandom_range(0, 1))
                send_write(addr, $urandom_range(0, 15), lens[lidx], 32'h5000_0000 + i*32, 4'hF);
            else
                send_read(addr, $urandom_range(0, 15), lens[lidx]);
        end
    endtask
endclass

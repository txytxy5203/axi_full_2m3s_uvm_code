class axi_smoke_single_rw_test extends axi_base_test;
    //   test:
    //   seq.addr = 0x0
    //   seq.data_base = 0xCAFE_1000
    //   seq.start(env.m0_agent.seqr)
    //          │
    //          ▼
    // seq.body():
    //   send_write(addr=0x0, id=0x1, len=1, data=0xCAFE_1000)
    //     │
    //     ├── start_item(tx)     → 向 sequencer 申请
    //     ├── 配置 tx 参数       → 设置 op, id, addr, data
    //     └── finish_item(tx)    → 发给 sequencer
    //          │
    //          ▼
    //   sequencer → driver (通过 seq_item_port)
    //          │
    //          ▼
    //   driver.drive_write(tr):
    //     AW: 发 awid, awaddr, awvalid → 握手
    //     W:  发 wdata, wstrb, wlast   → 握手
    //     (B 通道由 monitor 采样)
    
    
    // test（老板角色）：
    //   告诉 seq（自动化流程机器）：
    //     "流程参数：地址0x0、数据0xCAFE_1000、长度1"

    // seq（自动化流程机器）运转起来，body() 开始执行：
    //   ① send_write(...)： 
    //        制造一张"票据txn"（写，地址0x0，数据0xCAFE_1000）
    //        通过 start_item + finish_item 把票据交给 sequencer
    //   ② 等待 80ns
    //   ③ send_read(...)：
    //        制造另一张"票据txn"（读，地址0x0）
    //        交给 sequencer
    
    
    `uvm_component_utils(axi_smoke_single_rw_test)
    
    function new(string name = "axi_smoke_single_rw_test", uvm_component parent = null); 
        super.new(name, parent); 
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        axi_single_rw_seq seq;                  // 声明一个sequence变量
        phase.raise_objection(this);
        seq = axi_single_rw_seq::type_id::create("seq");    // 通过UVM工厂创建一个sequence对象

        // 配置 sequence 参数  并没有真正地发送
        seq.addr = 32'h0000_0000;
        seq.id = 4'h1;
        seq.burst_len = 1;
        seq.data_base = 32'hCAFE_1000;
        seq.start(env.m0_agent.seqr);
        wait_for_drain(300);
        phase.drop_objection(this);
    endtask
endclass

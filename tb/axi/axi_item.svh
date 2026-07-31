/*******************************************************************************
    核心数据结构
 *******************************************************************************/

class axi_txn extends uvm_sequence_item;
    // “一张票据” 每张具体的餐单
    rand axi_op_e op;
    // kind 字段表示 transaction 的不同阶段
    axi_kind_e kind;

    rand bit [AXI_ID_WIDTH-1:0]   id;
    rand bit [AXI_ADDR_WIDTH-1:0] addr;
    rand int unsigned             burst_len;    // burst 长度（1/2/4/8/16）
    rand bit [AXI_DATA_WIDTH-1:0] data[];       // 数据数组
    rand bit [(AXI_DATA_WIDTH/8)-1:0] strb[];   // 字节选通

    bit [1:0] resp;                // 响应（OKAY/DECERR）
    int master_id;                 // 哪个 Master 发出的（0 或 1）
    int slave_id;                  // 目标 Slave（从地址解码）
    bit out_of_order;              // 是否允许乱序
    int outstanding_depth;         // outstanding 深度

    constraint c_len {
        burst_len inside {1, 2, 4, 8, 16};
        data.size() == burst_len;
        strb.size() == burst_len;
    }

    constraint c_aligned {
        addr[1:0] == 2'b00;
    }

    function new(string name = "axi_txn");
        super.new(name);
        kind = AXI_KIND_REQ;
        resp = AXI_RESP_OKAY;
        master_id = -1;
        slave_id = -1;
        out_of_order = 1'b0;
        outstanding_depth = 0;
    endfunction

    `uvm_object_utils(axi_txn)

    function void alloc_arrays(int unsigned n);
        burst_len = n;
        data = new[n];
        strb = new[n];
        foreach (strb[i]) strb[i] = '1;
    endfunction

    function void do_copy(uvm_object rhs);
        axi_txn rhs_;
        if (!$cast(rhs_, rhs)) begin
            `uvm_fatal("AXI_ITEM", "do_copy cast failed")
        end
        super.do_copy(rhs);
        op = rhs_.op;
        kind = rhs_.kind;
        id = rhs_.id;
        addr = rhs_.addr;
        burst_len = rhs_.burst_len;
        resp = rhs_.resp;
        master_id = rhs_.master_id;
        slave_id = rhs_.slave_id;
        out_of_order = rhs_.out_of_order;
        outstanding_depth = rhs_.outstanding_depth;
        data = new[rhs_.data.size()];
        foreach (rhs_.data[i]) data[i] = rhs_.data[i];
        strb = new[rhs_.strb.size()];
        foreach (rhs_.strb[i]) strb[i] = rhs_.strb[i];
    endfunction

    function string kind_name();
        case (kind)
            AXI_KIND_REQ:        return "REQ";
            AXI_KIND_WRITE_CMD:  return "WRITE_CMD";
            AXI_KIND_WRITE_DATA: return "WRITE_DATA";
            AXI_KIND_WRITE_RSP:  return "WRITE_RSP";
            AXI_KIND_READ_CMD:   return "READ_CMD";
            AXI_KIND_READ_RSP:   return "READ_RSP";
            default:             return "UNKNOWN";
        endcase
    endfunction

    function string convert2string();
        return $sformatf("kind=%s op=%s mid=%0d id=0x%0h addr=0x%08h len=%0d slave=%0d resp=0x%0h ooo=%0d depth=%0d",
                         kind_name(), (op == AXI_WRITE) ? "WRITE" : "READ", master_id, id, addr,
                         burst_len, slave_id, resp, out_of_order, outstanding_depth);
    endfunction
endclass

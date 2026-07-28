/*******************************************************************************
 * File        : axi_utils.svh
 * Project     : AXI4 Full 2M3S UVM Teaching Project
 * Purpose     : AXI UVM agent source file used by the reusable master-side verification component.
 * Style       : Course-ready code with clear structure for RTL/UVM explanation.
 * Learn More  : www.bcbaoic.top
 *******************************************************************************/

function automatic int axi_decode_slave(bit [AXI_ADDR_WIDTH-1:0] addr);
    if (addr >= 32'h0000_0000 && addr <= 32'h0000_0FFF)
        return 0;
    else if (addr >= 32'h0001_0000 && addr <= 32'h0001_0FFF)
        return 1;
    else if (addr >= 32'h0002_0000 && addr <= 32'h0002_0FFF)
        return 2;
    else
        return 3;
endfunction

function automatic bit axi_legal_burst(bit [AXI_ADDR_WIDTH-1:0] addr, int unsigned burst_len);
    bit [AXI_ADDR_WIDTH-1:0] last_addr;
    last_addr = addr + ((burst_len - 1) << 2);
    return (axi_decode_slave(addr) != 3) && (axi_decode_slave(addr) == axi_decode_slave(last_addr));
endfunction

function automatic string axi_resp_name(bit [1:0] resp);
    case (resp)
        AXI_RESP_OKAY:   return "OKAY";
        AXI_RESP_DECERR: return "DECERR";
        default:         return $sformatf("RESP_%0h", resp);
    endcase
endfunction

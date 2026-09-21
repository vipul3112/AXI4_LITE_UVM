`ifndef SCB
`define SCB

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp#(axi_transaction, axi_scoreboard) ap_scb;
  bit [31:0] mem[$];

  int pass_count, fail_count;

  function new(string name = "axi_scoreboard", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_scb = new("ap_scb", this);
    //mem.delete();
    for(int i = 0; i < 16; i++)
      mem.push_back(32'h0);
  endfunction

  function void write(axi_transaction tx);
    if(tx.op == axi_transaction::WRITE)
      check_write(tx);
    else
      check_read(tx);
  endfunction

  function void check_write(axi_transaction tx);
    bit [31:0] word_addr;
    bit [1:0]  expected_resp;

    word_addr = tx.AWADDR[5:2];

    if(tx.AWADDR > 32'h3C) begin
      expected_resp = 2'b11; // DECERR
    end
    else if(tx.AWADDR[1:0] != 2'b00) begin
      expected_resp = 2'b10; // SLVERR - unaligned
    end
    else if(word_addr inside {[10:12]}) begin
      expected_resp = 2'b10; // SLVERR - write to Read-Only
    end
    else begin
      expected_resp = 2'b00; // OKAY
      if(tx.WSTRB[0]) mem[word_addr][7:0]   = tx.WDATA[7:0];
      if(tx.WSTRB[1]) mem[word_addr][15:8]  = tx.WDATA[15:8];
      if(tx.WSTRB[2]) mem[word_addr][23:16] = tx.WDATA[23:16];
      if(tx.WSTRB[3]) mem[word_addr][31:24] = tx.WDATA[31:24];
    end

    if(tx.BRESP !== expected_resp) begin
      `uvm_error(get_type_name(), $sformatf("Write MISMATCH addr=%0h exp_resp=%0b got_resp=%0b", tx.AWADDR, expected_resp, tx.BRESP))
      fail_count++;
    end else begin
      `uvm_info(get_type_name(), $sformatf("Write MATCH addr=%0h resp=%0b", tx.AWADDR, tx.BRESP), UVM_LOW)
      pass_count++;
    end
  endfunction

  function void check_read(axi_transaction tx);
    bit [31:0] word_addr;
    bit [31:0] expected_data;
    bit [1:0]  expected_resp;

    word_addr = tx.ARADDR[5:2];

    if(tx.ARADDR > 32'h3C) begin
      expected_resp = 2'b11; // DECERR
      expected_data = 32'h0;
    end
    else if(tx.ARADDR[1:0] != 2'b00) begin
      expected_resp = 2'b10; // SLVERR - unaligned
      expected_data = 32'h0;
    end
    else if(word_addr inside {[13:14]}) begin
      expected_resp = 2'b10; // SLVERR - read from Write-Only
      expected_data = 32'h0;
    end
    else begin
      expected_resp = 2'b00; // OKAY
      expected_data = mem[word_addr];
    end

    if(tx.RRESP !== expected_resp || (expected_resp == 2'b00 && tx.RDATA !== expected_data)) begin
      `uvm_error(get_type_name(), $sformatf("Read MISMATCH addr=%0h exp_resp=%0b got_resp=%0b exp_data=%0h got_data=%0h", tx.ARADDR, expected_resp, tx.RRESP, expected_data, tx.RDATA))
      fail_count++;
    end else begin
      `uvm_info(get_type_name(), $sformatf("Read MATCH addr=%0h resp=%0b data=%0h", tx.ARADDR, tx.RRESP, tx.RDATA), UVM_LOW)
      pass_count++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Scoreboard: PASS=%0d FAIL=%0d", pass_count, fail_count), UVM_LOW)
  endfunction

endclass

`endif
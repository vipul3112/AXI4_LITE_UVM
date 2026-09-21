`ifndef SUB
`define SUB

`uvm_analysis_imp_decl(_resp)

class axi_subscriber extends uvm_subscriber #(axi_transaction);
  `uvm_component_utils(axi_subscriber)

  uvm_analysis_imp_resp #(axi_transaction, axi_subscriber) resp_imp;

  axi_transaction tx;
  axi_transaction resp_tx;

  covergroup axi_cg;
    option.per_instance = 1;

    cp_op: coverpoint tx.op {
      bins write = {axi_transaction::WRITE};
      bins read  = {axi_transaction::READ};
    }

    cp_wstrb: coverpoint tx.WSTRB {
      bins all_zero    = {4'b0000};
      bins all_ones    = {4'b1111};
      bins byte0_only  = {4'b0001};
      bins byte1_only  = {4'b0010};
      bins byte2_only  = {4'b0100};
      bins byte3_only  = {4'b1000};
    }

    // WADDR, WDATA using 4 bins 0,mid,mid,all1
    cp_awaddr: coverpoint tx.AWADDR {
      bins zero     = {32'h0000_0000};
      bins low_mid  = {[32'h0000_0001 : 32'h3FFF_FFFF]};
      //bins high_mid = {[32'h4000_0000 : 32'hFFFF_FFFE]}; //
      //bins all_ones = {32'hFFFF_FFFF}; //
    }

    cp_wdata: coverpoint tx.WDATA {
      bins zero     = {32'h0000_0000};
      bins low_mid  = {[32'h0000_0001 : 32'h3FFF_FFFF]};
      bins high_mid = {[32'h4000_0000 : 32'hFFFF_FFFE]};
      //bins all_ones = {32'hFFFF_FFFF}; //
    }

    // ARADDR
    cp_araddr: coverpoint tx.ARADDR {
      bins zero     = {32'h0000_0000};
      bins low_mid  = {[32'h0000_0001 : 32'h3FFF_FFFF]};
      //bins high_mid = {[32'h4000_0000 : 32'hFFFF_FFFE]}; //
      //bins all_ones = {32'hFFFF_FFFF}; //
    }

  endgroup
  
  function new(string name = "axi_subscriber", uvm_component parent);
    super.new(name,parent);
    axi_cg = new();
    resp_imp = new("resp_imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    resp_tx = axi_transaction::type_id::create("resp_tx"); 
  endfunction

  function void write(axi_transaction t);
    tx = t;
    axi_cg.sample();
  endfunction

  function void write_resp(axi_transaction t);
    resp_tx = t;
    axi_cg.sample();
  endfunction

endclass

`endif

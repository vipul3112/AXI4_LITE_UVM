`ifndef OUT_MON
`define OUT_MON

class axi_output_monitor extends uvm_monitor;
  `uvm_component_utils(axi_output_monitor)
 
  uvm_analysis_port #(axi_transaction) ap_out_mon;
  virtual intf out_mvif;
  axi_transaction tx;
  
  function new(string name = "axi_output_monitor", uvm_component parent);
    super.new(name,parent);
    ap_out_mon = new("ap_out_mon", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this,"","out_mvif",out_mvif))
      `uvm_fatal(get_type_name(), "Interface out_mvif Not Created");
  endfunction
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      collect_write_resp();
      collect_read_data();
    join_none
  endtask
  
  
  task collect_write_resp();
    axi_transaction tx;
    forever begin
      @(out_mvif.mon_cb);
      if(out_mvif.mon_cb.BVALID && out_mvif.mon_cb.BREADY) begin
        tx = axi_transaction::type_id::create("tx");
        tx.BRESP = out_mvif.mon_cb.BRESP;
        ap_out_mon.write(tx);
      end
    end
  endtask

  task collect_read_data();
    axi_transaction tx;
    forever begin
      @(out_mvif.mon_cb);
      if(out_mvif.mon_cb.RVALID && out_mvif.mon_cb.RREADY) begin
        tx = axi_transaction::type_id::create("tx");
        tx.RDATA = out_mvif.mon_cb.RDATA;
        tx.RRESP = out_mvif.mon_cb.RRESP;
        ap_out_mon.write(tx);
      end
    end
  endtask
  
endclass


`endif
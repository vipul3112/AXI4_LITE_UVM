`ifndef IN_MON
`define IN_MON

class axi_input_monitor extends uvm_monitor;
  `uvm_component_utils(axi_input_monitor)
  
  virtual intf mvif;
  uvm_analysis_port #(axi_transaction) ap_mon;
  
  function new(string name = "axi_input_monitor", uvm_component parent);
    super.new(name,parent);
    ap_mon = new("ap_mon", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this, "", "mvif", mvif))
      `uvm_fatal(get_type_name(), "Interface mvif not created")
  endfunction
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      collect_write();
      collect_read();
    join_none
  endtask    
   
    task collect_write();
      axi_transaction aw_tx;
      bit [`AW-1:0] awaddr_q[$];
      bit [`DW-1:0] wdata_q[$];
      bit [`SW-1:0] wstrb_q[$];
      bit [1:0] 	bresp_q[$];
      
      fork
        ///AW channel
        forever begin
          @(mvif.mon_cb);
          if(mvif.mon_cb.AWVALID && mvif.mon_cb.AWREADY) begin
            awaddr_q.push_back(mvif.mon_cb.AWADDR);
          end
        end
        
        
        //W Channel
        forever begin
          @(mvif.mon_cb);
          if(mvif.mon_cb.WVALID && mvif.mon_cb.WREADY) begin
            wdata_q.push_back(mvif.mon_cb.WDATA);
            wstrb_q.push_back(mvif.mon_cb.WSTRB);
          end
        end
        
        // B channel
        forever begin
          @(mvif.mon_cb);
          if(mvif.mon_cb.BVALID && mvif.mon_cb.BREADY)
            bresp_q.push_back(mvif.mon_cb.BRESP);
        end
        
        
        // Merge AW W B
        
        forever begin
          wait(awaddr_q.size() > 0 && wdata_q.size() > 0 && bresp_q.size() > 0);
          aw_tx = axi_transaction::type_id::create("aw_tx");
          aw_tx.op     = axi_transaction::WRITE;
          aw_tx.AWADDR = awaddr_q.pop_front();
          aw_tx.WDATA  = wdata_q.pop_front();
          aw_tx.WSTRB  = wstrb_q.pop_front();
          aw_tx.BRESP  = bresp_q.pop_front();
          ap_mon.write(aw_tx);
        end        
        
      
      join      
    endtask
    
    
  task collect_read();
    axi_transaction r_tx;
    bit [`AW-1:0] araddr_q[$];
    bit [`DW-1:0] rdata_q[$];
    bit [1:0]     rresp_q[$];

    fork
      forever begin
        @(mvif.mon_cb);
        if(mvif.mon_cb.ARVALID && mvif.mon_cb.ARREADY)
          araddr_q.push_back(mvif.mon_cb.ARADDR);
      end
      
      forever begin
        @(mvif.mon_cb);
        if(mvif.mon_cb.RVALID && mvif.mon_cb.RREADY) begin
          rdata_q.push_back(mvif.mon_cb.RDATA);
          rresp_q.push_back(mvif.mon_cb.RRESP);
        end
      end
      
      forever begin
        wait(araddr_q.size() > 0 && rdata_q.size() > 0);
        r_tx = axi_transaction::type_id::create("r_tx");
        r_tx.op     = axi_transaction::READ;
        r_tx.ARADDR = araddr_q.pop_front();
        r_tx.RDATA  = rdata_q.pop_front();
        r_tx.RRESP  = rresp_q.pop_front();
        ap_mon.write(r_tx);
      end
    join
  endtask
  
 
    
    
endclass

`endif
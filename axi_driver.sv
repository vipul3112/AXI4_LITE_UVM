`ifndef DRV
`define DRV

class axi_driver extends uvm_driver #(axi_transaction);
  `uvm_component_utils(axi_driver)
  
  function new(string name = "axi_driver", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual intf dvif;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this, "", "dvif", dvif))
      `uvm_fatal(get_type_name(), "Interface dvif not created")
  endfunction
  
      
  //Run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    wait(dvif.ARESETn == 1'b0);
    @(dvif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req);
      sent_to_dut(req);
      seq_item_port.item_done();
    end
    
  endtask
      
    
  task sent_to_dut(axi_transaction tx);
    `uvm_info(get_type_name(), $sformatf("op=%s", tx.op.name()), UVM_LOW)
    if(tx.op == axi_transaction::WRITE) begin
      //fork
        address_channel(tx);
        data_channel(tx);
      //join_none
      response_channel(tx);
    end
    else begin
      read_address_channel(tx);
      read_data_channel(tx);
    end
  endtask
    
    
  task address_channel(axi_transaction tx);
    dvif.drv_cb.AWVALID <= 1;
    dvif.drv_cb.AWADDR  <= tx.AWADDR;
    do @(dvif.drv_cb); while(!dvif.drv_cb.AWREADY);
    dvif.drv_cb.AWVALID <= 0;
  endtask
    
    
  task data_channel(axi_transaction tx);
    dvif.drv_cb.WVALID <= 1;
    dvif.drv_cb.WDATA  <= tx.WDATA;
    dvif.drv_cb.WSTRB  <= tx.WSTRB;
    do @(dvif.drv_cb); while(!dvif.drv_cb.WREADY);
    dvif.drv_cb.WVALID <= 0;
  endtask
    
  
  task response_channel(axi_transaction tx);
    dvif.drv_cb.BREADY <= 1;
    do @(dvif.drv_cb); while(!dvif.drv_cb.BVALID);
    dvif.drv_cb.BREADY <= 0;
  endtask
    
  
  task read_address_channel(axi_transaction tx);
    dvif.drv_cb.ARVALID <= 1;
    dvif.drv_cb.ARADDR  <= tx.ARADDR;
    do @(dvif.drv_cb); while(!dvif.drv_cb.ARREADY);
    dvif.drv_cb.ARVALID <= 0;
  endtask

  task read_data_channel(axi_transaction tx);
    dvif.drv_cb.RREADY <= 1;
    do @(dvif.drv_cb); while(!dvif.drv_cb.RVALID);
    dvif.drv_cb.RREADY <= 0;
  endtask
    
    
    
endclass

`endif




































// `ifndef DRV
// `define DRV

// class axi_driver extends uvm_driver #(axi_transaction);
//   `uvm_component_utils(axi_driver)
  
//   function new(string name = "axi_driver", uvm_component parent);
//     super.new(name,parent);
//   endfunction
  
//   virtual intf dvif;
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if(!uvm_config_db#(virtual intf)::get(this, "", "dvif", dvif))
//       `uvm_fatal(get_type_name(), "Interface dvif not created")
//   endfunction
  
      
//   //Run phase
//   task run_phase(uvm_phase phase);
//     super.run_phase(phase);
    
//     wait(dvif.ARESETn == 1'b0);
//     @(dvif.drv_cb);
//     forever begin
//       seq_item_port.get_next_item(req);
//       sent_to_dut(req);
//       seq_item_port.item_done();
//     end
    
//   endtask
      
    
//   task sent_to_dut(axi_transaction tx);
//     `uvm_info(get_type_name(), $sformatf("op=%s", tx.op.name()), UVM_LOW)
//     if(tx.op == axi_transaction::WRITE) begin
//       if(tx.use_skew)
//         skewed_write(tx, tx.addr_first, tx.skew_cycles);
//       else begin
//         fork
//           address_channel(tx);
//           data_channel(tx);
//         join
//         response_channel(tx);
//       end
//     end
//     else begin
//       read_address_channel(tx);
//       read_data_channel(tx);
//     end
//   endtask
    
    
//   task address_channel(axi_transaction tx);
//     dvif.drv_cb.AWVALID <= 1;
//     dvif.drv_cb.AWADDR  <= tx.AWADDR;
//     do @(dvif.drv_cb); while(!dvif.drv_cb.AWREADY);
//     dvif.drv_cb.AWVALID <= 0;
//   endtask
    
    
//   task data_channel(axi_transaction tx);
//     dvif.drv_cb.WVALID <= 1;
//     dvif.drv_cb.WDATA  <= tx.WDATA;
//     dvif.drv_cb.WSTRB  <= tx.WSTRB;
//     do @(dvif.drv_cb); while(!dvif.drv_cb.WREADY);
//     dvif.drv_cb.WVALID <= 0;
//   endtask
    
  
//   task response_channel(axi_transaction tx);
//     dvif.drv_cb.BREADY <= 1;
//     do @(dvif.drv_cb); while(!dvif.drv_cb.BVALID);
//     dvif.drv_cb.BREADY <= 0;
//   endtask
    
  
//   task read_address_channel(axi_transaction tx);
//     dvif.drv_cb.ARVALID <= 1;
//     dvif.drv_cb.ARADDR  <= tx.ARADDR;
//     do @(dvif.drv_cb); while(!dvif.drv_cb.ARREADY);
//     dvif.drv_cb.ARVALID <= 0;
//   endtask

//   task read_data_channel(axi_transaction tx);
//     dvif.drv_cb.RREADY <= 1;
//     do @(dvif.drv_cb); while(!dvif.drv_cb.RVALID);
//     dvif.drv_cb.RREADY <= 0;
//   endtask
    
    
//   // AW first (or W first), skewed by N cycles -- exercises W_ADDR / W_DATA FSM states
//   task skewed_write(axi_transaction tx, bit addr_first, int skew_cycles);
//     if(addr_first) begin
//       fork
//         address_channel(tx);
//         begin
//           repeat(skew_cycles) @(dvif.drv_cb);
//           data_channel(tx);
//         end
//       join
//     end else begin
//       fork
//         data_channel(tx);
//         begin
//           repeat(skew_cycles) @(dvif.drv_cb);
//           address_channel(tx);
//         end
//       join
//     end
//     response_channel(tx);
//   endtask
    
    
// endclass

// `endif

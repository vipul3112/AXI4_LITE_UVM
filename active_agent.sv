`ifndef AGT
`define AGT

class axi_active_agent  extends uvm_agent;
  `uvm_component_utils(axi_active_agent )
  
  function new(string name = "axi_active_agent", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  axi_driver drv;
  axi_input_monitor mon;
  axi_sequencer sqr;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    drv = axi_driver::type_id::create("drv", this);
    sqr = axi_sequencer::type_id::create("sqr", this);
    mon = axi_input_monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
  
endclass

`endif
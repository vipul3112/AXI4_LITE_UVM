`ifndef ENV
`define ENV

class axi_environment extends uvm_env;
  `uvm_component_utils(axi_environment)
  
    
  axi_active_agent agt;
  axi_passive_agent pagt;
  axi_scoreboard scb;
  axi_subscriber sub;
  
  function new(string name = "axi_environment", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = axi_active_agent::type_id::create("agt",this);
    pagt = axi_passive_agent::type_id::create("pagt",this);
    scb = axi_scoreboard::type_id::create("scb", this);
    sub = axi_subscriber::type_id::create("sub", this);
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    //ACTIVE
    agt.mon.ap_mon.connect(scb.ap_scb);
    agt.mon.ap_mon.connect(sub.analysis_export);
    
//    PASSIVE
// 	pagt.pmon.ap_out_mon.connect(scb.ap_scb);
  endfunction
  
endclass

`endif

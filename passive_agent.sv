`ifndef PAGT
`define PAGT

class axi_passive_agent extends uvm_agent;
  `uvm_component_utils(axi_passive_agent)
  
  function new(string name = "axi_passive_agent", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  axi_output_monitor pmon;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    pmon = axi_output_monitor::type_id::create("pmon", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
endclass

`endif
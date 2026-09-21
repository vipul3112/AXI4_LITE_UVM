`ifndef TEST
`define TEST

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  function new(string name = "my_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  axi_environment env;
  //my_sequence seq;
  axi_sequence seq;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_environment::type_id::create("env",this);
    //seq = my_sequence::type_id::create("seq");
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq  = axi_sequence::type_id::create("seq");
    
    phase.raise_objection(this);
    seq.start(env.agt.sqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name() , "End of my_test Case", UVM_LOW);
  endtask
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),$sformatf("----------------------------------------------Coverage= %0.2f%% ------------------------",env.sub.axi_cg.get_coverage()),UVM_NONE)
  endfunction
  
  
endclass

`endif
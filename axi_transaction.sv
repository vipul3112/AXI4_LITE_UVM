`ifndef TRANS
`define TRANS

`include "axi_define.sv"

class axi_transaction extends uvm_sequence_item;
  
  function new(string name = "axi_transaction");
    super.new(name);
  endfunction
  
  typedef enum {WRITE, READ} op_e;
  rand op_e op;
  
  // Signals to Randomize //
  
  // Channel-1: WRITE ADDRESS CHANNEL
  rand bit AWVALID;
  rand bit [`AW-1:0]AWADDR;
  rand bit [2:0]AWPROT;
  bit AWREADY;
  
  // Channel-2: WRITE DATA CHANNEL
  rand bit WVALID;
  rand bit [`DW-1:0]WDATA;
  rand bit [`SW-1:0]WSTRB;
  bit WREADY;
  
  // Channel-3: WRITE RESPONSE CHANNEL
  rand bit BREADY;
  bit BVALID;
  bit [1:0] BRESP;
  
  // Channel-4: READ ADDRESS CHANNEL
  rand bit ARVALID;
  rand bit [`AW-1:0]ARADDR;
  rand bit [2:0]ARPROT;
  bit ARREADY;
  
  // Channel-5: READ DATA CHANNEL
  rand bit RVALID;
  rand bit [`DW-1:0]RDATA;
  rand bit [1:0]RRESP;
  bit RREADY;
  
  
  `uvm_object_utils_begin(axi_transaction)
  
  `uvm_field_enum(op_e, op, UVM_ALL_ON)
  
  `uvm_field_int( AWVALID, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( AWADDR, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( AWPROT, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( AWREADY, UVM_ALL_ON | UVM_DEC)
  
  `uvm_field_int( WVALID, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( WDATA, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( WSTRB, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( WREADY, UVM_ALL_ON | UVM_DEC)
  
  `uvm_field_int( BREADY, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( BVALID, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( BRESP, UVM_ALL_ON | UVM_DEC)
  
  `uvm_field_int( ARVALID, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( ARADDR, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( ARPROT, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( ARREADY, UVM_ALL_ON | UVM_DEC)
  
  `uvm_field_int( RVALID, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( RDATA, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( RRESP, UVM_ALL_ON | UVM_DEC)
  `uvm_field_int( RREADY, UVM_ALL_ON | UVM_DEC)
  
  `uvm_object_utils_end
  
  
endclass

`endif
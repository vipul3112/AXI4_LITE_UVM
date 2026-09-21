`include "axi_define.sv"
interface intf(input ACLK, input ARESETn);
  
  // Channel-1: WRITE ADDRESS CHANNEL
  logic AWVALID;
  logic AWREADY;
  logic [`AW-1:0]AWADDR;
  logic [2:0]AWPROT;
  
  // Channel-2: WRITE DATA CHANNEL
  logic WVALID;
  logic WREADY;
  logic [`DW-1:0]WDATA;
  logic [`SW-1:0]WSTRB;
  
  // Channel-3: WRITE RESPONSE CHANNEL
  logic BVALID;
  logic BREADY;
  logic [1:0] BRESP;
  
  // Channel-4: READ ADDRESS CHANNEL
  logic ARVALID;
  logic ARREADY;
  logic [`AW-1:0]ARADDR;
  logic [2:0]ARPROT;
  
  // Channel-5: READ DATA CHANNEL
  logic RVALID;
  logic RREADY;
  logic [`DW-1:0]RDATA;
  logic [1:0]RRESP;
  
  
  // Clocking block driver
  clocking drv_cb@(posedge ACLK);
    default input #1 output #0;
    
    input AWREADY;					//From channel-1
    input WREADY; 					// From channel-2
    input BVALID, BRESP; 			// From channel-3
    input ARREADY; 					// From channel-4
    input RDATA, RRESP, RVALID; 	// From channel-5
    
    output AWPROT,AWVALID, AWADDR; 	// From channel-1
    output WVALID, WSTRB, WDATA; 	//From channel-2
    output BREADY; 					// From channel-3
    output ARVALID, ARPROT, ARADDR; // From channel-4
    output RREADY; 					// From channel-5
    
  endclocking
  
  //Clocking Block Monitor
  clocking mon_cb@(posedge ACLK);
    default input #1;
    
    input AWREADY;					//From channel-1
    input WREADY; 					// From channel-2
    input BVALID, BRESP; 			// From channel-3
    input ARREADY; 					// From channel-4
    input RDATA, RRESP, RVALID; 	// From channel-5
    
    input AWPROT,AWVALID, AWADDR; 	// From channel-1
    input WVALID, WSTRB, WDATA; 	//From channel-2
    input BREADY; 					// From channel-3
    input ARVALID, ARPROT, ARADDR; // From channel-4
    input RREADY; 					// From channel-5
    
  endclocking
  
  
  // Modport Driver
  modport drv_mp(clocking drv_cb, input ACLK, input ARESETn);
    
  //Modport Monitor
  modport mon_mp(clocking mon_cb, input ACLK, input ARESETn);
  
  
  
endinterface
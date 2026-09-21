`include "uvm_macros.svh"
`include "axi_package.sv"
`include "axi_assertion.sv"
`include "design.sv"

module axi_top;
  import uvm_pkg::*;
  import pkg::*;
  
  bit ACLK;
  bit ARESETn;
  
  initial ACLK = 1'b1;
  always #5 ACLK = ~ACLK;
  
  task apply_reset();
    ARESETn = 0;
    repeat(2)@(posedge ACLK);
    ARESETn = 1;
  endtask
  
  initial begin
    apply_reset();
  end
  
  //Interface handle
  intf inf(ACLK, ARESETn);
  
  //setting interface
  initial begin
    uvm_config_db #(virtual intf)::set(null, "*", "dvif", inf);
uvm_config_db #(virtual intf)::set(null, "*", "mvif", inf);
uvm_config_db #(virtual intf)::set(null, "*", "out_mvif", inf);
  end
  
  //Binding assertion.sv
  
axi_assertions axi_assert_inst (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),
    .AWVALID (inf.AWVALID), .AWREADY(inf.AWREADY),
    .WVALID  (inf.WVALID),  .WREADY (inf.WREADY),
    .BVALID  (inf.BVALID),  .BREADY (inf.BREADY),
    .ARVALID (inf.ARVALID), .ARREADY(inf.ARREADY),
    .RVALID  (inf.RVALID),  .RREADY (inf.RREADY),
    .AWADDR  (inf.AWADDR),  .WDATA  (inf.WDATA),
    .ARADDR  (inf.ARADDR),
    .BRESP   (inf.BRESP),   .RRESP  (inf.RRESP)
);
  
  
  //SLAVE DUT INSTANCE HERE
  axi4_lite_slave #(
    .DATA_WIDTH(`DW),
    .ADDR_WIDTH(`AW),
    .MEM_DEPTH(16)
  ) dut (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),

    .AWADDR  (inf.AWADDR),
    .AWPROT  (inf.AWPROT),
    .AWVALID (inf.AWVALID),
    .AWREADY (inf.AWREADY),

    .WDATA   (inf.WDATA),
    .WSTRB   (inf.WSTRB),
    .WVALID  (inf.WVALID),
    .WREADY  (inf.WREADY),

    .BRESP   (inf.BRESP),
    .BVALID  (inf.BVALID),
    .BREADY  (inf.BREADY),

    .ARADDR  (inf.ARADDR),
    .ARPROT  (inf.ARPROT),
    .ARVALID (inf.ARVALID),
    .ARREADY (inf.ARREADY),

    .RDATA   (inf.RDATA),
    .RRESP   (inf.RRESP),
    .RVALID  (inf.RVALID),
    .RREADY  (inf.RREADY)
  );
  
  
  
  //WAVEFORM
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    run_test("my_test");
  end
  
  
  initial begin
  uvm_top.set_timeout(50000, 0);
end
  
  
endmodule

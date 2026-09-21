`ifndef ASSERT
`define ASSERT

module axi_assertions (
    input logic ACLK,
    input logic ARESETn,

    input logic AWVALID, AWREADY,
    input logic WVALID,  WREADY,
    input logic BVALID,  BREADY,
    input logic ARVALID, ARREADY,
    input logic RVALID,  RREADY,

    input logic [31:0] AWADDR,
    input logic [31:0] WDATA,
    input logic [31:0] ARADDR,
    input logic [1:0]  BRESP,
    input logic [1:0]  RRESP
);

  property p1;
    @(posedge ACLK) disable iff (!ARESETn)
    (AWVALID && !AWREADY) |=> AWVALID;
  endproperty
  assert property (p1);

  property p2;
    @(posedge ACLK) disable iff (!ARESETn)
    (WVALID && !WREADY) |-> ##1 WVALID;
  endproperty
    assert property (p2);

  property p3;
    @(posedge ACLK) disable iff (!ARESETn)
    (ARVALID && !ARREADY) |-> ##1 ARVALID;
  endproperty
    assert property (p3);

  property p4;
    @(posedge ACLK) disable iff (!ARESETn)
    (AWVALID && !AWREADY) |-> ##1 $stable(AWADDR);
  endproperty
    assert property (p4);

  property p5;
    @(posedge ACLK) disable iff (!ARESETn)
    (WVALID && !WREADY) |-> ##1 $stable(WDATA);
  endproperty
    assert property (p5);

//   property p6;
//     @(posedge ACLK) (!ARESETn) |-> (!AWVALID && !WVALID && !ARVALID && !BVALID && !RVALID);
//   endproperty
//       assert property (p6);

endmodule

`endif
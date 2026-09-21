`ifndef SEQ
`define SEQ

class axi_sequence extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_sequence)
  
  function new(string name = "axi_sequence");
    super.new(name);
  endfunction
  
  axi_transaction tx;
  
  int i;


  task write_sequence();

    for(i = 0; i < 16; i = i + 1) begin

      tx = axi_transaction::type_id::create("tx");
      start_item(tx);

      if(!tx.randomize() with {
        tx.op == axi_transaction::WRITE;
        tx.AWADDR[5:2] == i;
        tx.AWADDR[31:6] =='b0;
        tx.AWADDR[1:0] =='b0;
        tx.AWPROT inside {[0:7]};
        tx.AWVALID == 1'b1;
        tx.WSTRB inside {4'b0000, 4'b1111, 4'b0001,
                         4'b0010, 4'b0100, 4'b1000};
        tx.WVALID == 1'b1;
        tx.BREADY == 1'b1;
      })
        `uvm_error(get_type_name(), "write_sequence randomize FAILED")

      finish_item(tx);

    end

  endtask


  task read_sequence();

    for(i = 0; i < 16; i = i + 1) begin

      tx = axi_transaction::type_id::create("tx");
      start_item(tx);

      if(!tx.randomize() with {
        tx.op == axi_transaction::READ;
        tx.ARADDR[5:2] == i;
 	tx.ARADDR[31:6] =='b0;
        tx.ARADDR[1:0] =='b0;
        tx.ARPROT inside {[0:7]};
        tx.ARVALID == 1'b1;
      })
        `uvm_error(get_type_name(), "read_sequence randomize FAILED")

      finish_item(tx);

    end

  endtask



  

  task directed_write(bit [31:0] addr, bit [31:0] data);
      tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::WRITE;
                           tx.AWADDR == addr;
                           tx.AWPROT == 3'b111;
                           tx.AWVALID == 1'b1;
                           tx.WDATA == data;
                           tx.WSTRB == 4'b1111;
                           tx.WVALID == 1'b1;
                           tx.BREADY == 1'b1;
                          };
      finish_item(tx);

      tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::WRITE;
                           tx.AWADDR == 32'hffff_ffff;
                           tx.AWPROT == 3'b111;
                           tx.AWVALID == 1'b1;
                           tx.WDATA == data;
                           tx.WSTRB == 4'b1111;
                           tx.WVALID == 1'b1;
                           tx.BREADY == 1'b1;
                          };
      finish_item(tx);

  tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::WRITE;
                           tx.AWADDR == 32'h0000_0000;
                           tx.AWPROT == 3'b111;
                           tx.AWVALID == 1'b1;
                           tx.WDATA == data;
                           tx.WSTRB == 4'b1111;
                           tx.WVALID == 1'b1;
                           tx.BREADY == 1'b1;
                          };
      finish_item(tx);

  endtask

  task directed_read(bit [31:0] addr);
      tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::READ;
                           tx.ARADDR == addr;
                           tx.ARPROT == 3'b111;
                           tx.ARVALID == 1'b1;
                          };
      finish_item(tx);


      tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::READ;
                           tx.ARADDR == 32'hffff_ffff;
                           tx.ARPROT == 3'b111;
                           tx.ARVALID == 1'b1;
                          };
      finish_item(tx);

  tx = axi_transaction::type_id::create("tx");
      start_item(tx);
      tx.randomize() with {tx.op == axi_transaction::READ;
                           tx.ARADDR == 32'h0000_0000;
                           tx.ARPROT == 3'b111;
                           tx.ARVALID == 1'b1;
                          };
      finish_item(tx);
  endtask
  
  
  task directed_error_writeback_test();
      directed_write(32'h00, 32'hAAAA_BBBB);
      directed_write(32'h100, 32'h1111_1111);
      directed_read(32'h00);
  endtask
  
  
  task test_safe_address_regions();
    // Normal R/W region
    directed_write(32'h00, 32'hCAFE0000);
    directed_read(32'h00);

    // Read only, write krne pr SLVERR
    directed_write(32'h28, 32'hBAD0BAD0);   // expect SLVERR
    directed_read(32'h28);                   // expect valid read

    // Write-Only region -- read should SLVERR
    directed_write(32'h34, 32'hFEED0000);   // expect OKAY
    directed_read(32'h34);                   // expect SLVERR

    // Unaligned -- SLVERR
    directed_write(32'h01, 32'h0);
    directed_read(32'h02);

    // boundary
    directed_write(32'h3C, 32'hABCD1234);
    directed_read(32'h3C);
  endtask

  
  task test_out_of_range();
    directed_write(32'h100, 32'h0);
    directed_read(32'h100);
  endtask
  
  task test_corner_values();
    directed_write(32'hFFFF_FFFF, 32'hFFFF_FFFF);
    directed_write(32'h0000_0000, 32'h0000_0000);
    directed_read(32'hFFFF_FFFF);
    directed_read(32'h0000_0000);
  endtask
 
  task body();
    
    repeat(10) begin
      write_sequence();
      read_sequence();
    end
    

    test_safe_address_regions();

    test_out_of_range();
    directed_error_writeback_test();
    test_corner_values();

  endtask
  
  
endclass

`endif

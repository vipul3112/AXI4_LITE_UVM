`include "uvm_macros.svh"
`include "axi_define.sv"
`include "axi_interface.sv"

package pkg;
	import uvm_pkg::*;
	`include "axi_transaction.sv"
	`include "axi_sequence.sv"
	`include "axi_sequencer.sv"
	`include "axi_driver.sv"
	`include "axi_input_monitor.sv"
	`include "axi_output_monitor.sv"
	`include "active_agent.sv"
	`include "passive_agent.sv"
	`include "axi_scoreboard.sv"
	`include "axi_subscriber.sv"
	`include "axi_environment.sv"
	`include "my_test.sv"


endpackage
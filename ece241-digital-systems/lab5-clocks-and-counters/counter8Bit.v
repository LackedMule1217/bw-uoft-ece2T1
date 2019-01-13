// File Name: counter8bit
// Author: Shi Jie (Barney) Wei
// Date: October 17, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// Include alu, rca4bit, hexDecoder
`include "hexDecoder.v"



module counter8Bit (input [1:0] SW,
						  input [0:0] KEY,
						  output [6:0] HEX0, HEX1
					    );
	
	// Initiate variables
	wire enable = SW[1];
	wire clear_n = SW[0];
	wire clock = KEY[0];
	reg [7:0] dataOut = 8'b0000_0000;

	
	// counter8Bit implementation
	always @(posedge clock, negedge clear_n) begin
	
		if (!clear_n) dataOut <= 8'b0000_0000;
		
		else dataOut <= dataOut + 8'b0000_0001;
		
	end
	
	// Instantiate hexDecoder for output
	hexDecoder hex1 (
						  .signal(dataOut[7:4]),
						  .hex(HEX1)
						 );
	hexDecoder hex0 (
						  .signal(dataOut[3:0]),
						  .hex(HEX0)
						 );
	
endmodule

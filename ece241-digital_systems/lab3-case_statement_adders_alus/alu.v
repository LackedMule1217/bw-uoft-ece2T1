// Author: Barney Wei
// Date: September 28, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// include ripple-carry adder and hex decoder
`include "rca4bit.v"
`include "hexDecoder.v"

module alu (input [7:0] SW,
				input [2:0] KEY,
				output [7:0] LEDR,
				output [6:0] HEX0,
				output [6:0] HEX1,
				output [6:0] HEX2,
				output [6:0] HEX3,
				output [6:0] HEX4,
				output [6:0] HEX5);
	
	// assign parameters
	reg [7:0] ALUout = 0;
	wire [3:0] val_1 = SW[7:4];
	wire [3:0] val_2 = SW[3:0];
	wire [4:0] rcaout;
	reg [3:0] hexzeroin = 0;
	wire [6:0] hexzeroout;
	
	// compute rca4bit
	rca4bit rca (
				    .SW({val_1, val_2}),
				    .LEDR(rcaout)
				   );
	
	// declare always block
	always @(*)
	begin
	
		case (KEY[2:0])	// start case statement
					
			3'b000: ALUout[4:0] = rcaout; // case 0
			3'b001: ALUout[7:0] = val_1 + val_2; // case 1
			3'b010: ALUout[7:0] = {~(val_1 | val_2), ~(val_1 & val_2)}; // case 2
			3'b011: ALUout[7:0] = (val_1 | val_2) ? (8'b1100_0000) : (8'b0000_0000); // case 3
			3'b100: ALUout[7:0] = (((^~val_1) & (|val_1) & (~&val_1))
										 & ((^val_2) & ((val_2[0] & val_2[1]) | (val_2[2] & val_2[3])))) ? (8'b00111111) : (8'b0000_0000); // case 4
			3'b101: ALUout[7:0] = {val_2, ~val_1}; // case 5
			3'b110: ALUout[7:0] = {(val_1 ^ val_2), (val_1 ~^ val_2)}; // case 6
		
		default ALUout[7:0] = 0; // default case
		
		endcase
		
	end
	
	// assign LEDR[7:0] output
	assign LEDR[7:0] = ALUout[7:0];
	
	// instantiate HEX zero output
	hexDecoder hexzero (
							  .signal(hexzeroin),
							  .hex(hexzeroout)
							 );
	
	assign HEX1 = hexzeroout;
	assign HEX3 = hexzeroout;
	
	// instanate HEX value output
	hexDecoder hex0 (
						  .signal(val_2),
						  .hex(HEX0)
						 );
						  
	hexDecoder hex2 (
						  .signal(val_1),
						  .hex(HEX2)
						 );
						  
	hexDecoder hex4 (
						  .signal(ALUout[3:0]),
						  .hex(HEX4)
						 );
						  
	hexDecoder hex5 (
						  .signal(ALUout[7:4]),
						  .hex(HEX5)
						  );
								
	
endmodule

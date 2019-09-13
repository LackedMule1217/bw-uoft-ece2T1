// Author: Barney Wei
// Date: September 28, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// include ripple-carry adder and hex decoder
`include "rca4bit.v"

module alu (input [3:0] signal_A,
				input [3:0] signal_B,
				input [2:0] KEY,
				output reg [7:0] ALUout
			  );
	
	// assign parameters
	wire [3:0] val_1 = signal_A;
	wire [3:0] val_2 = signal_B;
	wire [4:0] rcaout;
	
	// compute rca4bit
	rca4bit rca (
				    .SW({val_1, val_2}),
				    .LEDR(rcaout)
				   );
	
	// declare always block
	always @(*)
	begin
	
		case (KEY[2:0])	// start case statement
					
			3'b000: ALUout[7:0] = {4'b0000, rcaout}; // case 0
			
			3'b001: ALUout[7:0] = val_1 + val_2; // case 1
			
			3'b010: ALUout[7:0] = {~(val_1 | val_2), ~(val_1 & val_2)}; // case 2
			
			3'b011: 
				if (val_1 | val_2)
					ALUout[7:0] = (8'b1100_0000); // case 3
				else
					ALUout[7:0] = {8{1'b0}};
					
			3'b100:
				if (((^~val_1) & (|val_1) & (~&val_1))
						& ((^val_2) & ((val_2[0] & val_2[1]) | (val_2[2] & val_2[3]))))
					ALUout[7:0] = (8'b00111111) ; // case 4
				else
					ALUout[7:0] = {8{1'b0}};
										 
			3'b101: ALUout[7:0] = {val_2, ~val_1}; // case 5
			
			3'b110: ALUout[7:0] = {(val_1 ^ val_2), (val_1 ~^ val_2)}; // case 6
			
		// no default to purposely create an inferred latch
		
		endcase
		
	end						
	
endmodule

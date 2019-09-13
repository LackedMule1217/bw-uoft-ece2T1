// Author: Barney Wei
// Date: September 27, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

module mux7to1 (SW, LEDR);

	// assign io
	input [9:0] SW;
	output reg [9:0] LEDR;
	
	// declare always block
	always @(*)
	begin
	
		case (SW[9:7])	// start case statement
					
			3'b000: LEDR[0] = SW[0]; // case 0
			3'b001: LEDR[0] = SW[1]; // case 1
			3'b010: LEDR[0] = SW[2]; // case 2
			3'b011: LEDR[0] = SW[3]; // case 3
			3'b100: LEDR[0] = SW[4]; // case 4
			3'b101: LEDR[0] = SW[5]; // case 5
			3'b110: LEDR[0] = SW[6]; // case 6
		
		default LEDR[0] = 0; // default case
		
		endcase
		
	end
	
endmodule

// Author: Barney Wei
// Date: October 13, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// include alu, rca4bit, hexDecoder
`include "alu.v"
`include "hexDecoder.v"

module aluwith8bitregister (input [9:0] SW,
									 input [3:0] KEY,
									 output [7:0] LEDR,
									 output [6:0] HEX0,
									 output [6:0] HEX1,
									 output [6:0] HEX2,
									 output [6:0] HEX3,
									 output [6:0] HEX4,
									 output [6:0] HEX5
									);
	
	// assign parameters
	wire [3:0] signal_A = SW[3:0];
	wire [2:0] key = KEY[3:1];
	wire [7:0] d;
	wire [6:0] hexzeroout;
	wire Clock = KEY[0];
	wire Reset_b = SW[9];
	reg [3:0] signal_B;
	reg [7:0] q;
	reg [3:0] hexzeroin = 0;
	
	
	// compute alu
		alu alu (
					.signal_A(signal_A),
					.signal_B(signal_B),
					.KEY(key),
					.ALUout(d)
				  );
	
	// declare always block for register
	always @(posedge Clock)
	begin
		
		if (Reset_b == 1'b0)
		begin
		
			q <= 0;
			
		end
		
		else
		begin
			q <= d;
		end
		
		signal_B <= q[3:0];
		
	end
	
	// assign LEDR[7:0] output
	assign LEDR[7:0] = q[7:0];
	
	// instantiate HEX zero output
	hexDecoder hexzero (
							  .signal(hexzeroin),
							  .hex(hexzeroout)
							 );
	
	assign HEX1 = hexzeroout;
	assign HEX2 = hexzeroout;
	assign HEX3 = hexzeroout;
	
	// instanate HEX value output
	hexDecoder hex0 (
						  .signal(signal_A),
						  .hex(HEX0)
						 );
						 
						  
	hexDecoder hex4 (
						  .signal(q[3:0]),
						  .hex(HEX4)
						 );
						  
	hexDecoder hex5 (
						  .signal(q[7:4]),
						  .hex(HEX5)
						  );
								
	
endmodule

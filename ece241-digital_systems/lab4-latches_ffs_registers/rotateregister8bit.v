// Author: Barney Wei
// Date: October 13, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// include alu, rca4bit, hexDecoder
`include "mux2to1.v"

module rotateregister8bit (input [9:0] SW,
									input [3:0] KEY,
									output [7:0] LEDR
								  );
	
	// assign parameters
	wire [7:0] D = SW[7:0];
	wire Reset_p = SW[9];
	wire Clock = KEY[0];
	wire ParallelLoadn = KEY[1];
	wire RotateRight = KEY[2];
	wire LSRight = KEY[3];
	
	wire [7:0] Q;
	
	wire [7:0] Qleftdata = {Q[6:0], Q[7]};
	wire [7:0] Qrightdata = {Q[0], Q[7:1]};
	wire [7:0] Qrightlogicaldata = Q >> 1;

	// instantiate register1bitwith2mux [7:0] using for loop
	
	register1bitwith2mux register8bit[7:0] (
													    .leftdata(Qleftdata),
													    .rightdata(Qrightdata),
														 .Qrightlogicaldata(Qrightlogicaldata),
													    .data_D(D),
													    .lsright(LSRight),
													    .rotateright(RotateRight),
													    .parallelloadn(ParallelLoadn),
													    .clock(Clock),
													    .reset(Reset_p),
													    .out_Q(Q)
													   );
	
	// assign LEDR[7:0] output
	assign LEDR = Q;					
	
endmodule



module register1bitwith2mux (input leftdata, rightdata, Qrightlogicaldata, data_D,
									  input lsright, rotateright, parallelloadn,
									  input clock, reset,
									  output reg out_Q);

	// instantiate variables
	wire rotatedata, datato_dff;
	
	// instantiates first mux - LSRight
	mux2to1 LSRight (
						  .SW({rightdata, Qrightlogicaldata, lsright}),
						  .LEDR(wire_rightdata)
						 );
	
	// instantiates sedond mux - LoadLeft
	mux2to1 LoadLeft (
							.SW({leftdata, wire_rightdata, rotateright}),
							.LEDR(rotatedata)
							);
	
	// instantiates third mux - loadn
	mux2to1 loadn (
						.SW({data_D, rotatedata, parallelloadn}),
						.LEDR(datato_dff)
						);
	
	// instantiates flip flop - ff
	always @(posedge clock)
	begin
		
		if (reset)
			
			out_Q <= 0;
			
		else
		
			out_Q <= datato_dff;
	
	end
	
endmodule

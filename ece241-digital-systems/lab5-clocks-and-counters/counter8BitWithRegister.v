// File Name: counter8BitWithRegister
// Author: Shi Jie (Barney) Wei
// Date: October 18, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// import external modules
`include "enabler26Bit.v"
`include "hexDecoder.v"



module counter8BitWithRegister (input [1:0] SW,
										  input [0:0] KEY,
										  input CLOCK_50,
										  output [6:0] HEX0, HEX1
										 );
	
	// Initiate variables
	wire clockEnabler;
	wire clear_n = KEY[0];
	reg [7:0] dataOut = 8'b0000_0000;
	
	
	// Instantiate enabler26Bit
	enabler26Bit enabler (
								 .SW(SW),
								 .CLOCK_50(CLOCK_50),
								 .clear_n(clear_n),
								 .enable(clockEnabler)
								);

	
	// counter8Bit implementation
	always @(posedge CLOCK_50, negedge clear_n) begin
	
		if (!clear_n) dataOut <= 8'b0000_0000;
		
		else if (clockEnabler) dataOut <= dataOut + 8'b0000_0001;
		
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

// File Name: clockDelayer
// Author: Shi Jie (Barney) Wei
// Date: November 25, 2018

/* 
Module that outputs a secondary clock which has a frequency a factor less than the input clock

INPUT
	A. clock						Clock
	B. resetN					Reset on negative clock edge
	c. numDelayCycle[6:0]	Number of input clock cycles to delay the output clock
OUTPUT
	A. delayedClock			Delayed clock
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



module clockDelayer(input clock, resetN,
						  input [6:0] numDelayCycle,
						  output reg delayedClock);
	// 0) Instantiate variables
	reg [6:0] cntDelayCycle;

	// 1) Sequential always block to update register values
	always @ (posedge clock) begin
		// 1.1) Reset
		if (~resetN) begin
			cntDelayCycle <= 7'd0;
			delayedClock <= 1'b0;
		end
		// 1.2) Update counter and output delayed clock
		else if (cntDelayCycle != numDelayCycle) begin
			cntDelayCycle <= cntDelayCycle + 1'd1;
			delayedClock <= 1'b0;
		end
		else begin
			cntDelayCycle <= 7'd0;
			delayedClock <= 1'b1;
		end
	end
endmodule

// File Name: randomValueGenerator
// Author: Shi Jie (Barney) Wei
// Date: November 18, 2018

/* 
Function that generates a random 32-bit integer within the specified range using a linear feedback shift
register (LFSR)

INPUT
	A. minVal[31:0]		Min value generated
	B. maxVal[31:0]		Max value -1 generated
	C. clock					Clock
	D. resetN				Reset on negative clock edge
OUTPUT
	A. randVal[31:0]		Random generated number
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



module randomValueGenerator(input [31:0] minVal,
									 input [31:0] maxVal,
									 input clock, resetN,
									 output [31:0] randVal
									 );
	
	// 0) Instantiate variables
	reg [31:0] random, randomNext, randomDone, maxMinDiff;
	reg [5:0] cnt, cntNext;
	wire feedback = random[31] ^ random[21] ^ random[1] ^ random[0];

	// 1) Combinational always block to update register values
	always @ (posedge clock) begin
		if (~resetN) begin
			random <= 32'hF;
			cnt <= 6'd0;
		end else begin
			random <= randomNext;
			cnt <= cntNext;
		end
	end
	
	// 2) Sequential always block to update register values
	always @ (*) begin
		maxMinDiff = maxVal - minVal;
		randomNext = {random[30:0], feedback};
		cntNext = cnt + 1'd1;
		if (cnt == 6'd32) begin
			cntNext = 6'd0;
			randomDone = random;
		end
	end
	
	// 3) Assign output values
	assign randVal = (randomDone % maxMinDiff) + minVal;
		
endmodule

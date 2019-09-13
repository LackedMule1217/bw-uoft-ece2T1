// File Name: main
// Author: Shi Jie (Barney) Wei
// Date: 01/15/19

/* 
INPUT
 	A. KEY
		A.1  KEY[0]			Resetn
		A.2  KEY[1]			Clock
	B. SW
		B.1 	SW[8:0]		DIN
		B.2	SW[9]			Run
OUTPUT
	A. LEDR
		A.1	LEDR[8:0]	Bus
		A.2	LEDR[9]		Done
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision

module main (KEY, SW, LEDR);
	input [1:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;	

	wire Resetn, Clock, Run, Done;
	wire [8:0] DIN, Bus;

	assign Resetn = KEY[0];
	assign Clock = KEY[1];	
	assign DIN = SW[8:0];
	assign Run = SW[9];

	// module proc(DIN, Resetn, Clock, Run, Done, Bus);
	proc U1 (DIN, Resetn, Clock, Run, Done, Bus);

	assign LEDR[8:0] = Bus;
	assign LEDR[9] = Done;

endmodule
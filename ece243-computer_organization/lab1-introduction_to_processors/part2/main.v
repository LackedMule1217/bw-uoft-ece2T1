// File Name: main
// Author: Shi Jie (Barney) Wei
// Date: 01/16/19

/* 
INPUT
 	A. KEY
		A.1  	KEY[0]		MClock
		A.2  	KEY[1]		PClock
	B. SW
		B.1 	SW[0]			Resetn
		B.2	SW[9]			Run
OUTPUT
	A. LEDR
		A.1	LEDR[8:0]	Bus
		A.2	LEDR[9]		Done
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision
`include "inst_mem.v"

module main (KEY, SW, LEDR);
	input [1:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;	

	wire Done, Resetn, PClock, MClock, Run;
	wire [8:0] DIN, Bus;
	wire [4:0] pc;

	assign Resetn = SW[0];
	assign MClock = KEY[0];
	assign PClock = KEY[1];
	assign Run = SW[9];

	// module proc(DIN, Resetn, Clock, Run, Done, BusWires);
	proc U1 (DIN, Resetn, PClock, Run, Done, Bus);
	assign LEDR[8:0] = Bus;
	assign LEDR[9] = Done;

	// you have to generate the inst_mem.v file by using the Quartus software
	inst_mem U2 (pc, MClock, DIN);
	count5 U3 (Resetn, MClock, pc);

endmodule

module count5 (Resetn, Clock, Q);
	input Resetn, Clock;
	output reg [4:0] Q;

	always @ (posedge Clock, negedge Resetn)
		if (Resetn == 0)
			Q <= 5'b00000;
		else
			Q <= Q + 1'b1;
 endmodule
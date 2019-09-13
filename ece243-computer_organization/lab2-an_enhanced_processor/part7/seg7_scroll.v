// File Name: seg7_scroll
// Author: Shi Jie (Barney) Wei
// Date: 01/19/19

/* 
INPUT
 	A. KEY
		A.1	KEY[0]		Resetn
	B. SW
		B.1 	SW[8:0]		Switch Port
		B.2	SW[9]			Run
	C. Clock
		C.1 	CLOCK_50
OUTPUT
	A. HEX
		A.1 	HEX0
		A.2 	HEX1
		A.3 	HEX2
		A.4 	HEX3
		A.5 	HEX4
		A.6 	HEX5
	A. LEDR
		A.1	LEDR[8:0]	LED_reg
		A.2	LEDR[9]		Run
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision


// Data written to registers R0 to R5 are sent to the H digits
module seg7_scroll (Data, Addr, Sel, Resetn, Clock, H5, H4, H3, H2, H1, H0);
	input [6:0] Data;
	input [2:0] Addr;
	input Sel, Resetn, Clock;
	output [6:0] H5, H4, H3, H2, H1, H0;
	
	regne hex0 (Data, Clock, Resetn, Sel && Addr == 3'd0, H0);
	regne hex1 (Data, Clock, Resetn, Sel && Addr == 3'd1, H1);
	regne hex2 (Data, Clock, Resetn, Sel && Addr == 3'd2, H2);
	regne hex3 (Data, Clock, Resetn, Sel && Addr == 3'd3, H3);
	regne hex4 (Data, Clock, Resetn, Sel && Addr == 3'd4, H4);
	regne hex5 (Data, Clock, Resetn, Sel && Addr == 3'd5, H5);
	
endmodule

module regne (R, Clock, Resetn, E, Q);
	parameter n = 7;
	input [n-1:0] R;
	input Clock, Resetn, E;
	output [n-1:0] Q;
	reg [n-1:0] Q;	
	
	always @(posedge Clock)
		if (Resetn == 0)
			Q <= {n{1'b0}};
		else if (E)
			Q <= R;
endmodule

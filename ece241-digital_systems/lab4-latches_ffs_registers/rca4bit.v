// Author: Barney Wei
// Date: September 28, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

module rca4bit (input [7:0] SW, output [4:0] LEDR);

	// declare wires for fa connections
	wire [3:0] wfaC;
	
	assign wfaC[0] = 0;

	// instantiate full adders (fa)
	fulladder fa1 (
						.val1(SW[0]),
						.val2(SW[4]),
						.Cin(wfaC[0]),
						.S(LEDR[0]),
						.Cout(wfaC[1])
						);  
	fulladder fa2 (
						.val1(SW[1]),
						.val2(SW[5]),
						.Cin(wfaC[1]),
						.S(LEDR[1]),
						.Cout(wfaC[2])
						);
	fulladder fa3 (
						.val1(SW[2]),
						.val2(SW[6]),
						.Cin(wfaC[2]),
						.S(LEDR[2]),
						.Cout(wfaC[3])
						);
	fulladder fa4 (
						.val1(SW[3]),
						.val2(SW[7]),
						.Cin(wfaC[3]),
						.S(LEDR[3]),
						.Cout(LEDR[4])
						);
	
endmodule	// main module for ripple-carry adder



module fulladder (input val1, val2, Cin,
						output S, Cout);

		assign S = val1 ^ val2 ^ Cin;
		assign Cout = (val1 & val2) | (val1 & Cin) | (val2 & Cin);

endmodule	// full adder helper module

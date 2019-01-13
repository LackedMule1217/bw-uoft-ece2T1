`timescale 1ns / 1ns // `timescale time_unit/time_precision


module mux2to1 (LEDR, SW);
	
	// assign io
	input [9:0] SW;
   output [9:0] LEDR;
					 
	// declare some wires for making connections
	wire w1, w2, w3, w4;
	
	// instantiate 74LS04 (NOT gate)
	v7404 NOT1 (
					.pin1(SW[1]),
					.pin2(w1)
					);
	
	// instantiate 74LS08 (AND gate)
	v7408 AND1 (
					.pin1(SW[0]),
					.pin2(w1),
					.pin3(w2),
					.pin4(SW[1]),
					.pin5(SW[2]),
					.pin6(w3)
					);
					
	// instantiate 74LS32 (OR gate)
	v7432 OR1 (
					.pin1(w2),
					.pin2(w3),
					.pin3(w4)
					);
					
	// pass signal to LEDR
	assign LEDR[0] = w4;
	
endmodule


module v7404 (input pin1, pin3, pin5, pin9, pin11, pin13,
				  output pin2, pin4, pin6, pin8, pin10, pin12);

	assign pin2 = !(pin1);
	assign pin4 = !(pin3);
	assign pin6 = !(pin5);
	
	assign pin8 = !(pin9);
	assign pin10 = !(pin11);
	assign pin12 = !(pin13);
	
endmodule // NOT gate (74LS04/05)


module v7408 (input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13,
				  output pin3, pin6, pin8, pin11);

	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	
	assign pin8 = pin9 & pin10;
	assign pin11 = pin12 & pin13;
	
endmodule // AND gate (74LS08)


module v7432 (input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13,
				  output pin3, pin6, pin8, pin11);

	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;
	
endmodule // OR gate (74LS32)
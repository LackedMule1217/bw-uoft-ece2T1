// OR gate (74LS32)
module v7432 (input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13,
				  output pin3, pin6, pin8, pin11);

	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;
	
endmodule
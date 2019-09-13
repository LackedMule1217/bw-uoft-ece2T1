`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

	reg Clock;
	reg ResetN;
	reg Run;
	reg [8:0] DIN;
	wire Done;
	wire [8:0] BusWires;

	initial begin
		Clock <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) Clock <= ~Clock;
	end
	
	initial begin
		ResetN <= 1'b0; Run <= 1'b0; DIN <= 9'd0;
		// 1) mvi
		//	   1.1) mvi R0, 0
		#10 ResetN <= 1'b1; DIN <= 9'b001000000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000000;
		//	   1.2) mvi R1, 1
		#10 DIN <= 9'b001001000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000001;
		//	   1.3) mvi R1, 2
		#10 DIN <= 9'b001010000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000010;
		//	   1.4) mvi R1, 3
		#10 DIN <= 9'b001011000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000011;
		//	   1.5) mvi R1, 4
		#10 DIN <= 9'b001100000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000100;
		//	   1.6) mvi R1, 5
		#10 DIN <= 9'b001101000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000101;
		//	   1.7) mvi R1, 6
		#10 DIN <= 9'b001110000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000110;
		//	   1.8) mvi R1, 7
		#10 DIN <= 9'b001111000;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0; DIN <= 9'b000000111;
		// 2) add
		//	   2.1) add  R2, R3
		#10 DIN <= 9'b010010011;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0;
		// 3) sub
		//	   2.1) sub  R5, R4
		#30 DIN <= 9'b011101100;
		#10 Run <= 1'b1;
		#10 Run <= 1'b0;
		
	end // initial

	proc U1 (DIN, ResetN, Clock, Run, Done, BusWires);

endmodule

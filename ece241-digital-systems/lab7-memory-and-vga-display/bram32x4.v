// File Name: bram32x4 (4-Bit)
// Author: Shi Jie (Barney) Wei
// Date: October 31, 2018

/* 
INPUT
 	A. KEY
		A.1  	KEY[0]		Input Clock
	B. SW
		B.1	SW[9]			Write Enable Input
		B.2 	SW[8:4]		Address Input
		B.3	SW[3:0]		Data Input
OUTPUT
	A. HEX
		A.1	HEX[5:4]		Address
		A.2	HEX2			Input Data
		A.3	HEX0			Output Data
*/

// import external modules
`include "ram32x4.v"



module bram32x4 (input [9:0] SW,
					  input [0:0] KEY,
					  output [6:0] HEX0, HEX2, HEX4, HEX5);

	// Declare wires
	wire[3:0] data_out;
	
	// Instantiate BRAM module
	ram32x4 r0 (
				   .address(SW[8:4]),
				   .clock(KEY[0]),
				   .data(SW[3:0]),
				   .wren(SW[9]),
				   .q(data_out[3:0])
				   );
				  
	// OUTPUT: HEX display
	hex_decoder h5 (		// Address
						 .hex_digit({3'd0, SW[8]}),
						 .segments(HEX5)
						 );
	
	hex_decoder h4 (		// Address
						 .hex_digit(SW[7:4]),
						 .segments(HEX4)
						 );
	
	hex_decoder h2 (		// Input Data
						 .hex_digit(SW[3:0]),
						 .segments(HEX2)
						 );
	
	hex_decoder h0 (		// Output Data
						 .hex_digit(data_out[3:0]),
						 .segments(HEX0)
						 );
	
endmodule



module hex_decoder(input [3:0] hex_digit,
						 output reg [6:0] segments);
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

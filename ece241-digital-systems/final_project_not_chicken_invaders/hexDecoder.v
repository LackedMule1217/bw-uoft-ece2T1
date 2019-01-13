// File Name: hexDecoder
// Author: Shi Jie (Barney) Wei
// Date: November 19, 2018

/* 
Module that encodes hex values to be outputed to HEX displays

INPUT
	A. hexVal[3:0]			Hex input value
OUTPUT
	A. hexSeg[6:0]			Encoded hex output to hex displays
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



module hexDecoder(input [3:0] hexVal,
						output reg [6:0] hexSeg);
	// 1) Sequential always block to output HEX values
	always @(*) begin
		case (hexVal)
			4'h0: hexSeg = 7'b100_0000;
			4'h1: hexSeg = 7'b111_1001;
			4'h2: hexSeg = 7'b010_0100;
			4'h3: hexSeg = 7'b011_0000;
			4'h4: hexSeg = 7'b001_1001;
			4'h5: hexSeg = 7'b001_0010;
			4'h6: hexSeg = 7'b000_0010;
			4'h7: hexSeg = 7'b111_1000;
			4'h8: hexSeg = 7'b000_0000;
			4'h9: hexSeg = 7'b001_1000;
			4'hA: hexSeg = 7'b000_1000;
			4'hB: hexSeg = 7'b000_0011;
			4'hC: hexSeg = 7'b100_0110;
			4'hD: hexSeg = 7'b010_0001;
			4'hE: hexSeg = 7'b000_0110;
			4'hF: hexSeg = 7'b000_1110;   
		default: hexSeg = 7'h7f;
		endcase
	end
endmodule

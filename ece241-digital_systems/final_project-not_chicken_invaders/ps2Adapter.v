// File Name: ps2Adapter
// Author: Shi Jie (Barney) Wei
// Date: November 14, 2018

/* 
INPUT
 	1) CLOCK_50				Clock
	2) resetN				Active low reset
	3) PS2_CLK				Bidirectionals
	4) PS2_DAT				Bidirectionals
OUTPUT
	1) HEX[7-0][6:0]		HEX output
	2) keyId[8:0]			Key ID for which key has been pressed in the given list: One-hot
				 [0]				NO KEY		F0
				 [1]				ESC			76
				 [2]				Enter			5A
				 [3]				UP				75
				 [4]				DOWN			72
				 [5]				LEFT			6B
				 [6]				RIGHT			74
				 [7]				A				1C
				 [8]				D				23
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



module ps2Adapter (
	// Inputs
	input CLOCK_50,
	input resetN,

	// Bidirectionals
	inout PS2_CLK,	PS2_DAT,
	
	// Outputs
	output [6:0] HEX0, HEX1,
	output reg [8:0] keyId
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg		[7:0]	last_data_received;
reg		[15:0] keyBuffer;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

 
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (!resetN) begin
		last_data_received <= 8'h00;
		keyBuffer <= 16'd0;
	end
	else begin
		if (ps2_key_pressed == 1'b1) begin
			keyBuffer[15:8] <= keyBuffer[7:0];
			keyBuffer[7:0] <= ps2_key_data;
		end
		
		if (keyBuffer[15:8] == 8'hF0) begin
			last_data_received <= 8'hF0;
		end
		else if (ps2_key_data != 8'hE0) begin
			last_data_received <= ps2_key_data;
		end
	end
	
	case (last_data_received)
		8'hF0:	keyId <= {8'd0, 1'b1};				// No KEY
		8'h76:	keyId <= {7'd0, 1'b1, 1'b0};		// ESC
		8'h5A:	keyId <= {6'd0, 1'b1, 2'b0};		// Enter
		8'h75:	keyId <= {5'd0, 1'b1, 3'b0};		// UP
		8'h72:	keyId <= {4'd0, 1'b1, 4'b0};		// DOWN
		8'h6B:	keyId <= {3'd0, 1'b1, 5'b0};		// LEFT
		8'h74:	keyId <= {2'd0, 1'b1, 6'b0};		// RIGHT
		8'h1C:	keyId <= {1'd0, 1'b1, 7'b0};		// A
		8'h23:	keyId <= {1'b1, 8'd0};				// D
	default 		keyId <= {9{1'dx}};
	endcase
end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLOCK_50),
	.reset				(~resetN),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

hexDecoder Segment0 (
	// Inputs
	.hexVal	(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.hexSeg	(HEX0)
);

hexDecoder Segment1 (
	// Inputs
	.hexVal	(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.hexSeg	(HEX1)
);

endmodule

// File Name: enabler26Bit
// Author: Shi Jie (Barney) Wei
// Date: October 18, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision



// Enabler to manipulate clock frequency
module enabler26Bit (input[1:0] SW, input CLOCK_50, clear_n, output reg enable);

	// Initiate variables
	wire clock = CLOCK_50;
	reg [25:0] timer = 26'd5;
	reg [25:0] countDwn;
	
	
	// Enabler implementation
	always @(posedge clock, negedge clear_n) begin
		
		if(!clear_n) begin
		
			countDwn = 26'd0;
		
			case(SW)
		
				2'b00: timer <= 26'd3 - 26'd1;
				
				2'b01: timer <= 26'd10 - 26'd1;
				
				2'b10: timer <= 26'd20 - 26'd1;
				
				2'b11: timer <= 26'd40 - 26'd1;
			
			endcase
		
		end else if (countDwn == 26'd0) begin
			
			countDwn <= timer;
			enable <= 1;
		
		end else begin
		
			enable <= 0;
			countDwn <= countDwn - 26'd1;
		
		end
		
	end
	
endmodule

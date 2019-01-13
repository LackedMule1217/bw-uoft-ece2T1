// File Name: morseCodeEncoder8Bit
// Author: Shi Jie (Barney) Wei
// Date: October 19, 2018

`timescale 1ns / 1ns // `timescale time_unit/time_precision

// import external modules
`include "enabler26Bit.v"



// 8-Bit Morse Code Encoder that Displays Letters S to Z on LED[0]
module morseCodeEncoder8Bit (input [2:0] SW,
									  input [1:0] KEY,
									  input CLOCK_50,
									  output reg [0:0] LEDR);
									  
	// Instantiate variables
	wire loadDisplay = KEY[1];			// Display the morse code
	wire clear_n = KEY[0];				// Asynchronous Clear
	wire enablerClock;					// Enable signal for clock
	reg [13:0] data;						// Morse code to be fed into FF
	
	
	// Instantiate enablr26Bit module
	enabler26Bit enabler (
								 .SW(2'b00),
								 .CLOCK_50(CLOCK_50),
								 .clear_n(clear_n),
								 .enable(enablerClock)
								);
	
	
	// Assign morseCode value based on letter (SW) input using always block
	always @(posedge CLOCK_50, negedge clear_n) begin
	
		if (~clear_n) begin
			
			data <= 14'd0;
			
			LEDR[0] <= 1'b0;

		end else if (loadDisplay) begin
		
			case (SW)
			
				3'b000: data <= 14'b00_0000_0001_0101;			// Case 1 (S - DDD)
				
				3'b001: data <= 14'b00_0000_0000_0111;			// Case 2 (T - L)
				
				3'b010: data <= 14'b00_0000_0101_0111;			// Case 3 (U - DDL)
				
				3'b011: data <= 14'b00_0001_0101_0111;			// Case 4 (V - DDDL)
				
				3'b100: data <= 14'b00_0001_0111_0111;			// Case 5 (W - DLL)
				
				3'b101: data <= 14'b00_0111_0101_0111;			// Case 6 (X - LDDL)
				
				3'b110: data <= 14'b11_1010_0111_0111;			// Case 7 (Y - LDLL)
				
				3'b111: data <= 14'b00_0111_0111_0101;			// Case 8 (Z - LLDD)

			endcase
		
		// Shift and output to LEDR[0] on enablerClock
		end else if (enablerClock) begin
		
			LEDR[0] <= data[0];
		
			data <= (data >> 1);
		
		end
		
	end

endmodule
	
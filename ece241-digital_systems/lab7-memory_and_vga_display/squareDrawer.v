// File Name: squareDrawer
// Author: Shi Jie (Barney) Wei
// Date: November 3, 2018

/* 
INPUT
 	A. KEY
		A.1 	KEY[0]		active low synchronous reset (reset FSM and registers but not clear the screen)
		A.2	KEY[1]		plot
		A.3	KEY[2]		clear screen to black
		A.4	KEY[3]		load
	B. SW
		B.1 	SW[9:7]		colour (RGB)
		B.2	SW[6:0]		input (X,Y)
	C. CLOCK
		C.1	CLOCK_50
OUTPUT
	A. VGA_ADAPTER
		A.1	VGA_R[7:0]		red colour value
		A.2	VGA_G[7:0]		green colour value
		A.3	VGA_B[7:0]		blue colour value
		A.4	VGA_HS			horizontal sync signals for the VGA monitor
		A.5	VGA_vs			vertical sync signals for the VGA monitor
		A.6	VGA_BLANK_N		signal is always 1 and is necessary for the VGA adapter to function correctly
		A.7	VGA_SYNC_N		syncronization signal for the monitor
		A.8	VGA_CLK			output clock signal operates at the frequency of 25 MHz and is derived from the clock input of the VGA Adapter
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision

// import external modules
// `include "vga_adapter.v"


module squareDrawer(input [3:0] KEY,
						  input [9:0] SW,
						  input CLOCK_50,
						  output [7:0] VGA_R, VGA_G, VGA_B,
						  output VGA_HS, VGA_vs, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	// assign wires
	wire reset_n, plot, clear_b, go;
	wire [2:0] colour_out;
	wire [7:0] xVal_out;
	wire [6:0] yVal_out;
	wire plot_out;
	
	wire [3:0] drawCnt_out;

	assign reset_n = KEY[0];
	assign plot = ~KEY[1];
	assign clear_b = ~KEY[2];
	assign go = ~KEY[3];

	// instantiate fsm
	fsm f0 (
			  .clk(CLOCK_50),
			  .reset_n(reset_n),
			  .plot(plot),
			  .clear_b(clear_b),
			  .go(go),
			
			  .colour_in(SW[9:7]),
			  .loc(SW[6:0]),
			
			  .colour_out(colour_out),
			  .xVal_out(xVal_out),
			  .yVal_out(yVal_out),
			  .plot_out(plot_out),
			  .drawCnt_out(drawCnt_out)
			  );
				
	// instantiate vga_adapter module
	/*vga_adapter VGA (
						 .resetn(reset_n),
						 .clock(CLOCK_50),
						 .colour(colour_out),
						 .x(xVal_out),
						 .y(yVal_out),
						 .plot(plot_out),
						 
						 .VGA_R(VGA_R),
						 .VGA_G(VGA_G),
						 .VGA_B(VGA_B),
						 .VGA_HS(VGA_HS),
						 .VGA_VS(VGA_VS),
						 .VGA_BLANK(VGA_BLANK_N),
						 .VGA_SYNC(VGA_SYNC_N),
						 .VGA_CLK(VGA_CLK)
						 );
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";*/
	
endmodule



module fsm (input clk, reset_n, plot, clear_b, go,
				input [2:0] colour_in,
				input [6:0] loc,
				output [2:0] colour_out,
				output [7:0] xVal_out,
				output [6:0] yVal_out,
				output plot_out,
				output reg [3:0] drawCnt_out);
				
	// declare inter-module wires
	wire id_load_x, id_load_y, id_load_colour, id_draw;
	wire [3:0] drawCnt;
	
	always@(*) drawCnt_out = drawCnt;
	
	control c0 (
					.clk(clk),
					.reset_n(reset_n),
					.plot(plot),
					.go(go),
					
					.id_load_x(id_load_x),
					.id_load_y(id_load_y),
					.id_load_colour(id_load_colour),
					.id_draw(id_draw),
					
					.drawCnt(drawCnt)
					);
					
	datapath d0 (
					 .clk(clk),
					 .reset_n(reset_n),
					 .clear_b(clear_b),
					 .drawCnt(drawCnt),
	
					 .id_load_x(id_load_x),
					 .id_load_y(id_load_y),
					 .id_load_colour(id_load_colour),
					 .id_draw(id_draw),
					 
					 .colour_in(colour_in),
					 .loc(loc),
					 .colour_out(colour_out),
					 .xVal_out(xVal_out),
					 .yVal_out(yVal_out),
					 .plot_out(plot_out)
					 );
				
endmodule



module control (input clk, reset_n, plot, go,
					 output reg id_load_x, id_load_y, id_load_colour, id_draw,
					 output reg [3:0] drawCnt);
					 
	reg [2:0] current_state, next_state;
	reg increment;

	localparam  LOAD_X_0				= 3'd0,
               LOAD_x_WAIT_1		= 3'd1,
               LOAD_Y_2				= 3'd2,
               LOAD_Y_WAIT_3		= 3'd3,
					DRAW_4				= 3'd4,
               DRAW_WAIT_5			= 3'd5;
					
	// Next state logic aka our state table
   always@(*)
   begin: state_table 
		increment = 1'd0;
	
		case (current_state)
			LOAD_X_0: next_state = go ? LOAD_x_WAIT_1 : LOAD_X_0;
			
			LOAD_x_WAIT_1: next_state = ~go ? LOAD_Y_2 : LOAD_x_WAIT_1;
			
			LOAD_Y_2: next_state = go ? LOAD_Y_WAIT_3 : LOAD_Y_2;
			
			LOAD_Y_WAIT_3: next_state = plot ? DRAW_4 : LOAD_Y_WAIT_3;
			
			DRAW_4: next_state = ~plot ? DRAW_WAIT_5 : DRAW_4;
			
			DRAW_WAIT_5:
			begin
				if (drawCnt == 4'd15) begin
					next_state = LOAD_X_0;
				end else begin
					increment = 1'd1;
					next_state = DRAW_WAIT_5;
				end
			end

		default:     next_state = 3'dx;
			endcase
	end // state_table

	// Output logic aka all of our datapath control signals
   always @(*)
   begin: enable_signals
		// By default make all our signals 0 to avoid latches.
      // This is a different style from using a default statement.
      // It makes the code easier to read.  If you add other out
      // signals be sure to assign a default value for them here.
		id_load_x = 1'b0;
		id_load_y = 1'b0;
		id_load_colour = 1'b0;
		id_draw = 1'b0;
		
		case (current_state)
			LOAD_X_0:		 	id_load_x = 1'b1;
			LOAD_Y_2:			id_load_y = 1'b1;
			DRAW_4:				id_load_colour = 1'b1;
			DRAW_WAIT_5:		id_draw = 1'b1;
		endcase
	end
	 
	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		if(~reset_n) begin
			current_state <= LOAD_X_0;
			drawCnt <= 4'd0;
		end else begin
			if (current_state == DRAW_WAIT_5)		drawCnt <= drawCnt + increment;
			else if (drawCnt == 4'd15) 				drawCnt <= 4'd0;
			current_state <= next_state;
		end
	end // state_FFS
 
endmodule



module datapath (input clk, reset_n, clear_b,
					  input [3:0] drawCnt,
					  input id_load_x, id_load_y, id_load_colour, id_draw,
					  input [2:0] colour_in,
					  input [6:0] loc,
					  output reg [2:0] colour_out,
					  output reg [7:0] xVal_out,
					  output reg [6:0] yVal_out,
					  output reg plot_out);
	
	// input registers
	reg [2:0] colour_out_temp;
	reg [7:0] xVal_out_temp;
	reg [6:0] yVal_out_temp;
	reg [14:0] clearCnt;
	
	always@(posedge clk) begin
		if(~reset_n) begin
			colour_out_temp <= 3'd0;
			xVal_out_temp <= 8'd0;
			yVal_out_temp <= 7'd0;
		end else begin
			if(id_load_x)					xVal_out_temp <= {1'd0, loc};		// load x_val
			else if(id_load_y)			yVal_out_temp <= loc;				// load y_val
			else if(id_load_colour)		colour_out_temp <= colour_in;		// load colour
		end
	end
	
	// output result register
	always@(posedge clk) begin
		if(~reset_n) begin
			colour_out <= 3'd0;
			xVal_out <= 8'd0;
			yVal_out <= 7'd0;
			clearCnt <= 15'd0;
		end
		if(clear_b || (clearCnt != 15'd0)) begin
			if(clearCnt == 19199)		clearCnt <= 15'd0;
			else 								clearCnt <= clearCnt + 1;
			colour_out <= 3'b000;
			xVal_out <= clearCnt / 120;
			yVal_out <= clearCnt % 120;
			plot_out <= 1'd1;
		end else begin
			if(id_draw) begin
				colour_out <= colour_out_temp;
				xVal_out <= xVal_out_temp + (drawCnt % 4);
				yVal_out <= yVal_out_temp + (drawCnt / 4);
				plot_out <= 1'd1;
			end else plot_out <= 1'd0;
		end
	end
					  
endmodule

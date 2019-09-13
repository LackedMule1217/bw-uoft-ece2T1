
module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,                        // On Board switches
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	
	// KEY[3] is used to load a position value (X or Y) into memory
	// KEY[2] clears the entire screen to black
	// KEY[1] plots a square at position (X, Y) with colour specified by SW[9:7]
	// KEY[0] is the system active low reset (Resetn) which resets the FSM and the registers
	input	[3:0]	KEY;
	
	// SW[9:7] are the input RGB signals, which can represent a total of 8 colours
	// SW[6:0] are used to input X and Y locations one after another into memory
	// locations are 7 bit, can only access 128 columns of the display
	input [9:0] SW;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	// ----------------------------------- Input set for VGA_draw_square module ---------------------------------------
	
	wire resetn;
	wire [6:0] pos_in;
	wire store_pos;
	wire clear_scr;
	wire plot;
	
	// assigned according to table above
	assign resetn = KEY[0];
	assign pos_in = SW[6:0];
	assign store_pos = ~KEY[3];
	assign clear_scr = ~KEY[2];
	assign plot = ~KEY[1];
	
	// ----------------------------------- Output set from VGA_draw_square module --------------------------------------
	// ----------------------------------- These are inputs to the VGA controller --------------------------------------

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// --------------------------------------- Instance of VGA controller  ---------------------------------------------
	
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	// ----------------------------------- Instance of VGA_draw_square module ---------------------------------------
			
	// Loads the position values sequentially into memory and generates the position vectors for a 4x4 square
	// For each position vector, it produces a high plot_enable which writes the pixel to the VGA frame buffer
	// Signals produced below: x, y, colour and writeEn for the VGA controller
	
	// instantiate fsm
	fsm f0 (
			  .clk(CLOCK_50),
			  .reset_n(resetn),
			
			  .colour_in(SW[2:0]),
			
			  .colour_out(colour),
			  .xVal_out(x),
			  .yVal_out(y),
			  .plot_out(writeEn)
			  );
	
endmodule



module fsm (input clk, reset_n,
				input [2:0] colour_in,
				output [2:0] colour_out,
				output [7:0] xVal_out,
				output [6:0] yVal_out,
				output plot_out, dirUp, dirRight,
				output wire [3:0] cntDraw, cntFps,
				output wire [19:0] cntHz);
				
	// declare inter-module wires
	wire id_draw_1, id_erase_3, id_update_dir_4;
	
	control c0 (
					.clk(clk),
					.reset_n(reset_n),
					
					.id_draw_1(id_draw_1),
					.id_erase_3(id_erase_3),
					.id_update_dir_4(id_update_dir_4),
					
					.cntDraw(cntDraw),
					.cntFps(cntFps),
					.cntHz(cntHz)
					);
					
	datapath d0 (
					 .clk(clk),
					 .reset_n(reset_n),
					 .cntDraw(cntDraw),
	
					 .id_draw_1(id_draw_1),
					 .id_erase_3(id_erase_3),
					 .id_update_dir_4(id_update_dir_4),
					 
					 .colour_in(colour_in),
					 .colour_out(colour_out),
					 .xVal_out(xVal_out),
					 .yVal_out(yVal_out),
					 .plot_out(plot_out),
					 .dirUp(dirUp),
					 .dirRight(dirRight)
					 );
				
endmodule



module control (input clk, reset_n,
					 output reg id_draw_1, id_erase_3, id_update_dir_4,
					 output reg [3:0] cntDraw, cntFps,
					 output reg [19:0] cntHz
					 );
					 
	reg [2:0] current_state, next_state;
	reg increment;

	localparam  RESET_INI_0				= 3'd0,
               DRAW_1					= 3'd1,
               COUNT_DELAY_2			= 3'd2,
               ERASE_3					= 3'd3,
					UPDATE_DIR_4			= 3'd4;
					
	// Next state logic aka our state table
   always@(*)
   begin: state_table 
		increment = 1'd0;
	
		case (current_state)
			RESET_INI_0: next_state = DRAW_1;
			
			DRAW_1:
			begin
				if (cntDraw == 4'd15) begin
					next_state = COUNT_DELAY_2;
				end else begin
					increment = 1'd1;
					next_state = DRAW_1;
				end
			end
			
			COUNT_DELAY_2:
			begin
				if (cntFps == 4'd15) begin
					next_state = ERASE_3;
				end else begin
					increment = 1'd1;
					next_state = COUNT_DELAY_2;
				end
			end
			
			ERASE_3:
			begin
				if (cntDraw == 4'd15) begin
					next_state = UPDATE_DIR_4;
				end else begin
					increment = 1'd1;
					next_state = ERASE_3;
				end
			end
			
			UPDATE_DIR_4: next_state = DRAW_1;

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
		id_draw_1 = 1'b0;
		id_erase_3 = 1'b0;
		id_update_dir_4 = 1'b0;
		
		case (current_state)
			DRAW_1:					id_draw_1 = 1'b1;
			ERASE_3:					id_erase_3 = 1'b1;
			UPDATE_DIR_4:			id_update_dir_4 = 1'b1;
		endcase
	end
	 
	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		if (!reset_n) begin
			current_state <= RESET_INI_0;
			cntDraw <= 4'd0;
			cntFps <= 4'd0;
			cntHz <= 20'd0;
		end else begin
			if (current_state == DRAW_1) begin
				if (cntDraw == 4'd15) 							cntDraw <= 4'd0;
				else													cntDraw <= cntDraw + increment;
			end
			if (current_state == COUNT_DELAY_2) begin
				if (cntHz == 20'd833333) begin		// cntHz = 20'd833333 for 60Hz
					cntHz <= 20'd0;
					if (cntFps == 4'd15) 						cntFps <= 4'd0;
					else 												cntFps <= cntFps + increment;
				end else												cntHz <= cntHz + increment;
			end
			if (current_state == ERASE_3) begin
				cntFps <= 4'd0;
				cntHz <= 20'd0;
				if (cntDraw == 4'd15) 							cntDraw <= 4'd0;
				else													cntDraw <= cntDraw + increment;
			end
			
			current_state <= next_state;
		end
	end // state_FFS
 
endmodule



module datapath (input clk, reset_n,
					  input [3:0] cntDraw,
					  input id_draw_1, id_erase_3, id_update_dir_4,
					  input [2:0] colour_in,
					  output reg [2:0] colour_out,
					  output reg [7:0] xVal_out,
					  output reg [6:0] yVal_out,
					  output reg plot_out, dirUp, dirRight);
	
	// registers
	reg [2:0] colour_out_temp;
	reg [7:0] xVal_out_temp;
	reg [6:0] yVal_out_temp;
					  
	// output result register
	always@(posedge clk) begin
		if (!reset_n) begin
			colour_out <= 3'd0;
			xVal_out <= 8'd156;
			yVal_out <= 7'd0;
			xVal_out_temp <= 8'd156;
			yVal_out_temp <= 7'd0;
			dirUp <= 1'd0;
			dirRight <= 1'd0;
		end else begin
			if (id_draw_1) begin
				colour_out <= colour_in;
				xVal_out <= xVal_out_temp + (cntDraw % 4);
				yVal_out <= yVal_out_temp + (cntDraw / 4);
				plot_out <= 1'd1;
			end else if (id_erase_3) begin
				colour_out <= 3'b000;
				xVal_out <= xVal_out_temp + (cntDraw % 4);
				yVal_out <= yVal_out_temp + (cntDraw / 4);
				plot_out <= 1'd1;
			end else if (id_update_dir_4) begin
				// x-axis direction movement
				if (xVal_out == 0 && !dirRight) begin
					xVal_out_temp <= xVal_out_temp + 8'd1;
					dirRight <= 1;
				end else if (xVal_out == 156 && dirRight) begin
					xVal_out_temp <= xVal_out_temp - 8'd1;
					dirRight <= 0;
				end else if (dirRight) begin
					xVal_out_temp <= xVal_out_temp + 8'd1;
				end else	begin
					xVal_out_temp <= xVal_out_temp - 8'd1;
				end
				// y-axis direction movement
				if (yVal_out == 0 && dirUp) begin
					yVal_out_temp <= yVal_out_temp + 7'd1;
					dirUp <= 0;
				end else if (yVal_out == 116 && !dirUp) begin
					yVal_out_temp <= yVal_out_temp - 7'd1;
					dirUp <= 1;
				end else if (dirUp) begin
					yVal_out_temp <= yVal_out_temp - 7'd1;
				end else	begin
					yVal_out_temp <= yVal_out_temp + 7'd1;
				end
			end else plot_out <= 1'd0;
		end
	end
					  
endmodule

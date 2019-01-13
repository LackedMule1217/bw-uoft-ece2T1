 xzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz                
 `timescale 1ns/1ns

module VGA_draw_square
	(
		input [6:0] pos_in, 	// position input from the board
		input [2:0] color_in,// color_in usually flows out to color_out unless screen is to be cleared (after high clear_scr), in this case it is 0
		input store_pos, 		// store_pos stores X or Y and moves the FSM to the next wait state
		input clear_scr, 		// clear_scr clears the screen by drawing a black pixel into every position
		input plot, 			// plot starts the plotting process after positions have been loaded
		input clock,			// On board clock, 50 MHz for the DE1
		input resetn, 			// active low, resets the FSM and clears the datapath registers
		output plot_enable, 	// generated 16 times to draw a 4x4 square
		output [7:0] X, 		// X is position from left, padded with a 0 bit since VGA adapter addresses 160 pixels in x
		output [6:0] Y,		// Y is position from top, not padded since VGA adapter addresses 120 pixels in y
		output [2:0] color_out
	);
	
	// wires that connect FSM to datapath
	
	// loads X and Y positions into datapath registers
	wire load_X, load_Y;
	
	// tells the datapth to start computing new positions to draw the square
	wire plot_counter_enable;
	
	// tells the datapath to start computing new positions to clear the screen
	wire clear_counter_enable;
	
	// tells the FSM that plotting is complete and to start looking for input positions again
	wire plot_complete;
	
	// tells the FSM that clearing is complete and to start looking for input positions again
	wire clear_complete;
	
	// color_in flows to color out unless the screen is being cleared, in which case it is 000 i.e. black
	assign color_out = (clear_counter_enable) ? 3'b000 : color_in;

	control FSM(
	
		.clock(clock),
		.resetn(resetn),
		
		// -------------------------------- inputs that affect FSM state -------------------------------------
		.store_pos(store_pos),
		.plot(plot),
		.clear_scr(clear_scr),
		
		.plot_complete(plot_complete),
		.clear_complete(clear_complete),
		
		// ------------------------------------ outputs to the datapath --------------------------------------
		
		// control signals to set position vector
		.ld_X(load_X),
		.ld_Y(load_Y),
		
		.plot_counter_enable(plot_counter_enable),
		.clear_counter_enable(clear_counter_enable),
		
		// --------------------------------- plot_enable to the VGA adapter ----------------------------------
		.plot_enable(plot_enable)
	
	);
	
	datapath position_manip(
	
		.clock(clock),
		.resetn(resetn),
		
		// ------------------------------------ control signals from FSM --------------------------------------
		.ld_X(load_X),
		.ld_Y(load_Y),
		.plot_counter_enable(plot_counter_enable),
		.clear_counter_enable(clear_counter_enable),
		
		// ------------------------------------ data input and output --------------------------------------
		.data_in(pos_in),
		
		.data_out_X(X),
		.data_out_Y(Y),
		
		// ----------------------------------------- outputs to FSM -----------------------------------------
		// ----------------------- inform the FSM that plotting or clearing is complete--------------------------------
		
		.plot_complete(plot_complete),
		.clear_complete(clear_complete)
	
	);

endmodule

module control(input clock, resetn, store_pos, plot, clear_scr, plot_complete, clear_complete,
					output reg ld_X, ld_Y, plot_counter_enable, clear_counter_enable, plot_enable);

	
	reg [2:0] current_state, next_state;
	
	// FSM stays in S_PLOT_CYCLE_0 until all the 16 pixels have been drawn
	
	localparam S_LOAD_X = 3'd0,
				  S_LOAD_X_WAIT = 3'd1,
				  S_LOAD_Y = 3'd2,
				  S_LOAD_Y_WAIT = 3'd3,
				  S_PLOT_HOLD = 3'd4,
				  S_PLOT_CYCLE_0 = 3'd5,
				  S_CLEAR_SCR = 3'd6;
	
	// ----------------------------------------- state table  ------------------------------------------------
	
	always @(*)
	begin: state_table
		
		case (current_state)
			S_LOAD_X: next_state = store_pos ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = store_pos ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = store_pos ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = store_pos ? S_LOAD_Y_WAIT : S_PLOT_HOLD;
			S_PLOT_HOLD: next_state = plot ? S_PLOT_CYCLE_0 : S_PLOT_HOLD;
			S_PLOT_CYCLE_0: next_state = plot_complete ? S_LOAD_X : S_PLOT_CYCLE_0;
			S_CLEAR_SCR: next_state = clear_complete ? S_LOAD_X : S_CLEAR_SCR; // keep clearing until all pixels are 000
			default: next_state = S_LOAD_X;
		endcase
		
	end // state_table
	
	// ------------------------------- output logic i.e. control signal logic  ----------------------------------------
	
	always @(*)
	begin: control_signals
	
		// prevent latching by assuming all control signals to be 0 at the beginning
		ld_X = 1'b0;
		ld_Y = 1'b0;
		plot_counter_enable = 1'b0;
		clear_counter_enable = 1'b0;
		plot_enable = 1'b0;
		
		case (current_state)
			S_LOAD_X: ld_X = 1'b1;
			S_LOAD_Y: ld_Y = 1'b1;
			S_PLOT_CYCLE_0:
			begin
				// start counting positions
				plot_counter_enable = 1'b1;
				plot_enable = 1'b1;
			end
			S_CLEAR_SCR:
			begin
				// start clear counter
				clear_counter_enable = 1'b1;
				plot_enable = 1'b1;
			end
			// no default required since no latches and we already assigned default values
		endcase
	
	end // control_signals
	
	// -------------------------------------- current state registers  ------------------------------------------------
	always @(posedge clock)
	begin: state_FFs
		if (!resetn)
			current_state <= S_LOAD_X;
		else if (clear_scr == 1'b1)
			current_state <= S_CLEAR_SCR;
		else
			current_state <= next_state; // at each clock cycle, move to the next computed state
	end // state_FFs

endmodule

module datapath(input clock, resetn, ld_X, ld_Y, plot_counter_enable, clear_counter_enable,
					 input [6:0] data_in,
					 output reg [7:0] data_out_X, output reg [6:0] data_out_Y, 
					 output plot_complete, output clear_complete);
	
	// input registers, initial X and Y pos
	reg [7:0] X_pos;
	reg [6:0] Y_pos;
	
	// computed X and Y pos
	reg [7:0] counter_out_X;
	reg [6:0] counter_out_Y;
	
	// ---------------------------------------- datapath output table  ------------------------------------------------
	
	always @(posedge clock)
	begin
	
		if (!resetn) begin
			X_pos <= 8'b0;
			Y_pos <= 7'b0;
		end
		else begin
			if (ld_X)
				X_pos <= {1'b0, data_in}; // pad with one bit to adjust for size difference
			if (ld_Y)
				Y_pos <= data_in;
		end
	end
	
	// -------------------------------------- output position registers  -----------------------------------------------
	
	always @(posedge clock)
	begin
		if (!resetn)
			data_out_X <= 0;
		else
			data_out_X <= counter_out_X; // counter_out_X is registered to keep it stable for 1 clock cycle
	end
	
	always @(posedge clock)
	begin
		if (!resetn)
			data_out_Y <= 0;
		else
			data_out_Y <= counter_out_Y; // counter_out_X is registered to keep it stable for 1 clock cycle
	end
	
	// -------------------------------------- position counting logic  -----------------------------------------------
	wire [3:0] position_count;
	
	wire [13:0] clear_position_count;
	
	counter4 count_pos(
	
		.clock(clock),
		.resetn(plot_counter_enable),
		
		.Q(position_count),
		.count_complete(plot_complete)
	
	);
	
	counter13 count_clear_pos(
	
		.clock(clock),
		.resetn(clear_counter_enable),
		
		.Q(clear_position_count),
		.count_complete(clear_complete)
	
	);
	
	// ---------------------------------- new position calculation logic  --------------------------------------------
	
	always @(posedge clock)
	begin
		if (clear_counter_enable == 1'b1) begin
			// if counter is enabled and not completed yet, increment over all pixels on the screen
			counter_out_X <= (clear_position_count / 128);
			counter_out_Y <= (clear_position_count % 128);
		end else begin
			// else in a non-clearing state, prepare to draw a square
			counter_out_X <= X_pos + (position_count % 4);
			counter_out_Y <= Y_pos + (position_count / 4);
		end
	end
	
endmodule

module counter4(input clock, resetn, output reg [3:0] Q, output reg count_complete);

	// counter counts from 00000 to 10000 and then resets (0 to 16)
	
	reg [4:0] Q_buffer;  

	always @(posedge clock)
	begin
	
		count_complete = 1'b0;
	
		if (resetn == 1'b0)
			Q_buffer <= 0;
		else if (Q_buffer == 5'b10001) begin
			count_complete = 1'b1;
			Q_buffer <= 0;
		end else
			Q_buffer <= Q_buffer + 1;
			
		Q <= Q_buffer[3:0];
		
	end

endmodule

module counter13(input clock, resetn, output reg [13:0] Q, output reg count_complete);

	// counter counts from 0 to 16384 (128^2) and then resets
	
	reg [14:0] Q_buffer;  

	always @(posedge clock)
	begin
	
		count_complete = 1'b0;
	
		if (resetn == 1'b0)
			Q_buffer <= 0;
		else if (Q_buffer == 15'b100000000000001) begin
			count_complete = 1'b1;
			Q_buffer <= 0;
		end else
			Q_buffer <= Q_buffer + 1;
			
		Q <= Q_buffer[13:0];
		
	end

endmodule

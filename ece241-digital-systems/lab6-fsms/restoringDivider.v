// File Name: restoringDivider (4-Bit)
// Author: Shi Jie (Barney) Wei
// Date: October 30, 2018

/* 
INPUT
 	A. KEY
		A.1  KEY[0]			Active high synchronous reset
		A.2 ~KEY[1]			Load (Go)
	B. SW
		B.1 	SW[3:0]		Divisor Value
		B.2	SW[7:4]		Dividend Value
	C. CLOCK
		C.1 	CLOCK_50		Input Clock
OUTPUT
	A. LEDR
		A.1	LEDR[3:0]	Quotient Value
	B. HEX
		B.1	HEX0			Divisor Value
		B.2	HEX2			Dividend Value
		B.3	HEX4			Quotiant Value
		B.4	HEX5			Remainder Value
		B.5	HEX[1|3]		0 Value
	C. data_result
		C.1 data_result[3:0]		Dividend Value -> Quotiant
		C.2 data_result[8:4]		Register A -> Remainder
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision

module restoringDivider(input [7:0] SW,
								input [1:0] KEY,
								input CLOCK_50,
								output [3:0] LEDR,
								output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	 // assign wires
    wire reset_n;
    wire go;

    wire [8:0] data_result;
	 wire [2:0] shift_cnt;
    assign go = ~KEY[1];
    assign reset_n = KEY[0];
	 
	 // instantiate fsm
	 fsm f0 (
				.clk(CLOCK_50),
				.reset_n(reset_n),
				.go(go),
				.data_in(SW[7:0]),
				.data_result(data_result),
				.shift_cnt(shift_cnt)
				);
      
    assign LEDR[3:0] = data_result[3:0];		// Quotiant Value

    hex_decoder H0(		// Divisor Value
        .hex_digit(SW[3:0]), 
        .segments(HEX0)
        );
		  
    hex_decoder H1(		// 0 Value
        .hex_digit(4'd0), 
        .segments(HEX1)
        );

    hex_decoder H2(		// Divident Value
        .hex_digit(SW[7:4]), 
        .segments(HEX2)
        );

    hex_decoder H3(		// 0 Value
        .hex_digit(4'd0), 
        .segments(HEX3)
        );

        
    hex_decoder H4(		// Quotiant Value
        .hex_digit(data_result[3:0]), 
        .segments(HEX4)
        );

    hex_decoder H5(		// Remainder Value
        .hex_digit(data_result[7:4]), 
        .segments(HEX5)
        );
		  
endmodule



module fsm (input clk, reset_n, go,
				input [7:0] data_in,
				output [8:0] data_result,
				output [2:0] shift_cnt);
				
	// declare wires
	wire reg_A_msb, divi_lsb;
	wire id_load, id_shift_left, id_sub_reg_a, id_restore_reg_a, id_shift_done;
	
	control c0 (
					.clk(clk),
					.reset_n(reset_n),
					.go(go),
					.reg_A_msb(reg_A_msb),
					
					.divi_lsb(divi_lsb),
					.shift_cnt(shift_cnt),
					
					.id_load(id_load),
					.id_shift_left(id_shift_left),
					.id_sub_reg_a(id_sub_reg_a),
					.id_sub_reg_a_wait(id_sub_reg_a_wait),
					.id_restore_reg_a(id_restore_reg_a),
					.id_shift_done(id_shift_done)
					);
					
	datapath d0 (
					 .clk(clk),
					 .reset_n(reset_n),
					 .divi_lsb(divi_lsb),
	
					 .id_load(id_load),
					 .id_shift_left(id_shift_left),
					 .id_sub_reg_a(id_sub_reg_a),
					 .id_sub_reg_a_wait(id_sub_reg_a_wait),
					 .id_restore_reg_a(id_restore_reg_a),
					 .id_shift_done(id_shift_done),
					 
					 .data_in(data_in),
					 .reg_A_msb(reg_A_msb),
					 .data_result(data_result)
					 );
				
endmodule



module control (input clk, reset_n, go,
					 input reg_A_msb,
					 output reg divi_lsb,
					 output reg [2:0] shift_cnt,
					 output reg id_load, id_shift_left, id_sub_reg_a, id_sub_reg_a_wait, id_restore_reg_a, id_shift_done);
					 
	reg [5:0] current_state, next_state;
	reg increment;

	localparam  LOAD_DIVS_DIVI_1				= 5'd0,
               LOAD_DIVS_DIVI_WAIT_2		= 5'd1,
               SHIFT_LEFT_3					= 5'd2,
               SUB_REG_A_4						= 5'd3,
					SUB_REG_A_WAIT_5				= 5'd4,
               RESTORE_REG_A_6				= 5'd5,
               SHIFT_DONE_7					= 5'd6;
					
	// Next state logic aka our state table
   always@(*)
   begin: state_table 
		divi_lsb = 1'b0;
		increment = 1'b0;
	
		case (current_state)
			LOAD_DIVS_DIVI_1:		// Loop in current state until value is input
			begin
				next_state = go ? LOAD_DIVS_DIVI_WAIT_2 : LOAD_DIVS_DIVI_1;
			end
			
			LOAD_DIVS_DIVI_WAIT_2: next_state = go ? LOAD_DIVS_DIVI_WAIT_2 : SHIFT_LEFT_3;	// Loop in current state until go signal goes low
			
			SHIFT_LEFT_3:
			begin
				increment = 1'b1;
				next_state = SUB_REG_A_4;
			end
			
			SUB_REG_A_4:
			begin
				next_state = SUB_REG_A_WAIT_5;
			end
			
			SUB_REG_A_WAIT_5:
			begin
				if (reg_A_msb == 0) divi_lsb = 1'b1;
			
				if ((shift_cnt == 3'd4) && (reg_A_msb == 0)) next_state = SHIFT_DONE_7;
				else if (reg_A_msb == 1) next_state = RESTORE_REG_A_6;
				else next_state = SHIFT_LEFT_3;
			end
			
			RESTORE_REG_A_6: next_state = (shift_cnt == 3'd4) ? SHIFT_DONE_7 : SHIFT_LEFT_3;
			
			SHIFT_DONE_7:																							// Done division, start over after
			begin
				next_state = SHIFT_DONE_7;
			end
		default:     next_state = 5'bx_xxxx;
			endcase
	end // state_table

	// Output logic aka all of our datapath control signals
   always @(*)
   begin: enable_signals
		// By default make all our signals 0 to avoid latches.
      // This is a different style from using a default statement.
      // It makes the code easier to read.  If you add other out
      // signals be sure to assign a default value for them here.
		id_load = 1'b0;
		id_shift_left = 1'b0;
		id_sub_reg_a = 1'b0;
		id_sub_reg_a_wait = 1'b0;
		id_restore_reg_a = 1'b0;
		id_shift_done = 1'b0;
		
		case (current_state)
			LOAD_DIVS_DIVI_1: 	id_load = 1'b1;
			SHIFT_LEFT_3:			id_shift_left = 1'b1;
			SUB_REG_A_4:			id_sub_reg_a = 1'b1;
			SUB_REG_A_WAIT_5:		id_sub_reg_a_wait = 1'b1;
			RESTORE_REG_A_6:		id_restore_reg_a = 1'b1;
			SHIFT_DONE_7:			id_shift_done = 1'b1;
		endcase
	end
	 
	// current_state registers
	always@(posedge clk)
	begin: state_FFs
		shift_cnt <= shift_cnt + increment;
	
		if(reset_n)
		begin
			current_state <= LOAD_DIVS_DIVI_1;
			shift_cnt <= 3'd0;
		end else
			current_state <= next_state;
	end // state_FFS
 
endmodule



module datapath (input clk, reset_n,
					  input divi_lsb,
					  input id_load, id_shift_left, id_sub_reg_a, id_sub_reg_a_wait, id_restore_reg_a, id_shift_done,
					  input [7:0] data_in,
					  output reg reg_A_msb,
					  output reg [8:0] data_result);

	// input registers
	reg [4:0] divisor;
	reg [8:0] data_result_temp;
	
	    // Registers a, b, c, x with respective input logic
	always@(posedge clk) begin
		if(reset_n) begin
			divisor <= 4'd0;
			data_result_temp <= 8'd0;
		end
	else begin
		if(id_load)						// load dividend, divisor, and register A
		begin
			divisor <= {1'b0, data_in[3:0]};
			data_result_temp <= {5'd0, data_in[7:4]};
		end
		
		if(id_shift_left)				// shift left one bit
			data_result_temp <= data_result_temp << 1'b1;
		
		if(id_sub_reg_a)
			data_result_temp[8:4] <= data_result_temp[8:4] - divisor;
		
		if(id_sub_reg_a_wait)
			data_result_temp[0] <= divi_lsb;
		
		if(id_restore_reg_a)
			data_result_temp[8:4] <= data_result_temp[8:4] + divisor;
		end
	end
	
	// Output result register
	always@(posedge clk) begin
		if(reset_n) 					data_result <= 8'd0; 
		else begin
			// data_result <= data_result_temp;
			if(id_shift_done)			data_result <= data_result_temp;
		end
	end
	
	always@(*) reg_A_msb <= data_result_temp[8];

					  
endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
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

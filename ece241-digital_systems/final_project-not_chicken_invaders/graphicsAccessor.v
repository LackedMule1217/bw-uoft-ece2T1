// File Name: graphicsAccessor
// Author: Shi Jie (Barney) Wei
// Date: November 13, 2018

/* 
INPUT
 	A. pixelId[20:0]		Pixel ID to access its colour in memory
	B. graphicId[4:0]		Graphic ID to determine which graphic to access
	C. clock					Clock
	D. clear					Synchronous active high clear output to 0
OUTPUT
	A. colour[2:0]			Colour Bit to feed into VGA adapter
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



// Import graphic memory blocks
`include "mem/asteroid_mem.v"						// graphicId = 0
`include "mem/background_mem.v"					// graphicId = 1
`include "mem/chicken_mem.v"						// graphicId = 2
`include "mem/coming_soon_mem.v"					// graphicId = 3
`include "mem/coming_soon_select_mem.v"		// graphicId = 4
`include "mem/credits_mem.v"						// graphicId = 5
`include "mem/credits_page_mem.v"				// graphicId = 6
`include "mem/credits_select_mem.v"				// graphicId = 7
`include "mem/game_modes_mem.v"					// graphicId = 8
`include "mem/game_modes_select_mem.v"			// graphicId = 9
`include "mem/game_over_mem.v"					// graphicId = 10
`include "mem/muse_me_mem.v"						// graphicId = 11
`include "mem/muse_me_select_mem.v"				// graphicId = 12
`include "mem/one_player_mem.v"					// graphicId = 13
`include "mem/one_player_select_mem.v"			// graphicId = 14
`include "mem/ship_mem.v"							// graphicId = 15
`include "mem/ship2_mem.v"							// graphicId = 16
`include "mem/stay_tuned_page_mem.v"			// graphicId = 17
`include "mem/tie_fighter_mem.v"					// graphicId = 18
`include "mem/title_mem.v"							// graphicId = 19
`include "mem/two_player_mem.v"					// graphicId = 20
`include "mem/two_player_select_mem.v"			// graphicId = 21



module graphicsAccessor(input [20:0] pixelId,
								input [4:0] graphicId,
								input clock, clear,
								output reg [2:0] colour);
	// 0) Instantiate variables
	wire writeEnable = 1'd0;					// Read-only
	wire [2:0] data = 3'd0;						// Data-input, not useful since its read-only
	localparam										// Total number of pixels for each graphic
		asteroidPx 				= 11'd1444,			// graphicId = 0
		backgroundPx			= 17'd76800,		// graphicId = 1
		chickenPx 				= 12'd3600,			// graphicId = 2
		comingSoonPx 			= 13'd4344,			// graphicId = 3
		comingSoonSelectPx 	= 13'd4344,			// graphicId = 4
		creditsPx 				= 13'd4344,			// graphicId = 5
		creditsPagePx 			= 15'd29904,		// graphicId = 6
		creditsSelectPx		= 13'd4344,			// graphicId = 7
		gameModesPx 			= 13'd4344,			// graphicId = 8
		gameModesSelectPx 	= 13'd4344,			// graphicId = 9
		gameOverPx 				= 14'd13500,		// graphicId = 10
		museMePx 				= 13'd6516,			// graphicId = 11
		museMeSelectPx 		= 13'd6516,			// graphicId = 12
		onePlayerPx 			= 13'd6516,			// graphicId = 13
		onePlayerSelectPx 	= 13'd6516,			// graphicId = 14
		shipPx 					= 11'd1444,			// graphicId = 15
		ship2Px 					= 11'd1444,			// graphicId = 16
		stayTunedPagePx 		= 15'd29904,		// graphicId = 17
		tieFighterPx			= 12'd2500,			// graphicId = 18
		titlePx					= 15'd20916,		// graphicId = 19
		twoPlayerPx 			= 13'd6516,			// graphicId = 20
		twoPlayerSelectPx 	= 13'd6516;			// graphicId = 21
	// 	0.01) asteroid_mem (11-bit)
	reg [10:0] asteroidAddress;
	wire [2:0] asteroidColour;
	// 	0.02) background_mem (17-bit)
	reg [16:0] backgroundAddress;
	wire [2:0] backgroundColour;
	// 	0.03) chicken_mem (12-bit)
	reg [11:0] chickenAddress;
	wire [2:0] chickenColour;
	// 	0.04) coming_soon_mem (13-bit)
	reg [12:0] comingSoonAddress;
	wire [2:0] comingSoonColour;
	// 	0.05) coming_soon_select_mem (13-bit)
	reg [12:0] comingSoonSelectAddress;
	wire [2:0] comingSoonSelectColour;
	// 	0.06) credits_mem (13-bit)
	reg [12:0] creditsAddress;
	wire [2:0] creditsColour;
	// 	0.07) credits_page_mem (15-bit)
	reg [14:0] creditsPageAddress;
	wire [2:0] creditsPageColour;
	// 	0.08) credits_select_mem (13-bit)
	reg [12:0] creditsSelectAddress;
	wire [2:0] creditsSelectColour;
	// 	0.09) game_modes_mem (13-bit)
	reg [12:0] gameModesAddress;
	wire [2:0] gameModesColour;
	// 	0.10) game_modes_select_mem (13-bit)
	reg [12:0] gameModesSelectAddress;
	wire [2:0] gameModesSelectColour;
	// 	0.11) game_over_mem (14-bit)
	reg [13:0] gameOverAddress;
	wire [2:0] gameOverColour;
	// 	0.12) muse_me_select_mem (13-bit)
	reg [12:0] museMeAddress;
	wire [2:0] museMeColour;
	// 	0.13) muse_me_select_mem (13-bit)
	reg [12:0] museMeSelectAddress;
	wire [2:0] museMeSelectColour;
	// 	0.14) one_player_mem (13-bit)
	reg [12:0] onePlayerAddress;
	wire [2:0] onePlayerColour;
	// 	0.15) one_player_select_mem (13-bit)
	reg [12:0] onePlayerSelectAddress;
	wire [2:0] onePlayerSelectColour;
	// 	0.16) ship_mem (11-bit)
	reg [10:0] shipAddress;
	wire [2:0] shipColour;
	// 	0.17) ship_mem (11-bit)
	reg [10:0] ship2Address;
	wire [2:0] ship2Colour;
	// 	0.18) stay_tuned_page_mem (15-bit)
	reg [14:0] stayTunedPageAddress;
	wire [2:0] stayTunedPageColour;
	// 	0.19) tie_fighter_mem (12-bit)
	reg [11:0] tieFighterAddress;
	wire [2:0] tieFighterColour;
	// 	0.20) title_mem (15-bit)
	reg [14:0] titleAddress;
	wire [2:0] titleColour;
	// 	0.21) two_player_mem (13-bit)
	reg [12:0] twoPlayerAddress;
	wire [2:0] twoPlayerColour;
	// 	0.22) two_player_select_mem (13-bit)
	reg [12:0] twoPlayerSelectAddress;
	wire [2:0] twoPlayerSelectColour;
	
	// 1) Set address values
	always @ (*) begin
		if (!clear) begin
			case (graphicId)
				5'd0: 	asteroidAddress 				= pixelId[10:0];
				5'd1: 	backgroundAddress 			= pixelId[16:0];
				5'd2: 	chickenAddress 				= pixelId[11:0];
				5'd3: 	comingSoonAddress 			= pixelId[12:0];
				5'd4: 	comingSoonSelectAddress 	= pixelId[12:0];
				5'd5: 	creditsAddress 				= pixelId[12:0];
				5'd6: 	creditsPageAddress 			= pixelId[14:0];
				5'd7: 	creditsSelectAddress 		= pixelId[12:0];
				5'd8: 	gameModesAddress 				= pixelId[12:0];
				5'd9: 	gameModesSelectAddress 		= pixelId[12:0];
				5'd10: 	gameOverAddress 				= pixelId[13:0];
				5'd11: 	museMeAddress 					= pixelId[12:0];
				5'd12: 	museMeSelectAddress 			= pixelId[12:0];
				5'd13: 	onePlayerAddress 				= pixelId[12:0];
				5'd14: 	onePlayerSelectAddress 		= pixelId[12:0];
				5'd15: 	shipAddress 					= pixelId[10:0];
				5'd16: 	ship2Address 					= pixelId[10:0];
				5'd17: 	stayTunedPageAddress 		= pixelId[14:0];
				5'd18: 	tieFighterAddress 			= pixelId[11:0];
				5'd19: 	titleAddress 					= pixelId[14:0];
				5'd20: 	twoPlayerAddress 				= pixelId[12:0];
				5'd21: 	twoPlayerSelectAddress 		= pixelId[12:0];
			endcase
		end
	end
	
	// 2) Instantiate memory modules
	// 	2.1) asteroid_mem (11-bit)
	asteroid_mem asteroidMem (
																.address(asteroidAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(asteroidColour));
	// 	2.2) background_mem (17-bit)
	background_mem backgroundMem (
																.address(backgroundAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(backgroundColour));
	// 	2.3) chicken_mem (12-bit)
	chicken_mem chickenMem (
																.address(chickenAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(chickenColour));
	// 	2.4) coming_soon_mem (13-bit)
	coming_soon_mem comingSoonMem (
																.address(comingSoonAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(comingSoonColour));
	// 	2.5) coming_soon_select_mem (13-bit)
	coming_soon_select_mem comingSoonSelectMem (
																.address(comingSoonSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(comingSoonSelectColour));
	// 	2.6) credits_mem (13-bit)
	credits_mem creditsMem (
																.address(creditsAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(creditsColour));
	// 	2.7) credits_page_mem (15-bit)
	credits_page_mem creditsPageMem (
																.address(creditsPageAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(creditsPageColour));
	// 	2.8) credits_select_mem (13-bit)
	credits_select_mem creditsSelectMem (
																.address(creditsSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(creditsSelectColour));
	// 	2.9) game_modes_mem (13-bit)
	game_modes_mem gameModesMem (
																.address(gameModesAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(gameModesColour));
	// 	2.10) game_modes_select_mem (13-bit)
	game_modes_select_mem gameModesSelectMem (
																.address(gameModesSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(gameModesSelectColour));
	// 	2.11) game_over_mem (14-bit)
	game_over_mem gameOverMem (
																.address(gameOverAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(gameOverColour));
	// 	2.12) muse_me_mem (13-bit)
	muse_me_mem museMeMem (
																.address(museMeAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(museMeColour));
	// 	2.13) muse_me_select_mem (13-bit)
	muse_me_select_mem museMeSelectMem (
																.address(museMeSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(museMeSelectColour));
	// 	2.14) one_player_mem (13-bit)
	one_player_mem onePlayerMem (
																.address(onePlayerAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(onePlayerColour));
	// 	2.15) one_player_select_mem (13-bit)
	one_player_select_mem onePlayerSelectMem (
																.address(onePlayerSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(onePlayerSelectColour));
	// 	2.16) ship_mem (11-bit)
	ship_mem shipMem (
																.address(shipAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(shipColour));
	// 	2.17) ship_mem (11-bit)
	ship2_mem ship2Mem (
																.address(ship2Address),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(ship2Colour));
	// 	2.18) stay_tuned_page_mem (15-bit)
	stay_tuned_page_mem stayTunedPageMem (
																.address(stayTunedPageAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(stayTunedPageColour));
	// 	2.19) tie_fighter_mem (12-bit)
	tie_fighter_mem tieFighterMem (
																.address(tieFighterAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(tieFighterColour));
	// 	2.20) title_mem (15-bit)
	title_mem titleMem (
																.address(titleAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(titleColour));
	// 	2.21) two_player_mem (13-bit)
	two_player_mem twoPlayerMem (
																.address(twoPlayerAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(twoPlayerColour));
	// 	2.22) two_player_select_mem (13-bit)
	two_player_select_mem twoPlayerSelectMem (
																.address(twoPlayerSelectAddress),
																.clock(clock),
																.data(data),
																.wren(writeEnable),
																.q(twoPlayerSelectColour));
										
	// 3) Output colour based on graphicId
	always @ (posedge clock) begin
		if (clear) colour <= 3'd0;
		else begin
			case (graphicId)
				5'd0: 	colour <= asteroidColour;
				5'd1: 	colour <= backgroundColour;
				5'd2: 	colour <= chickenColour;
				5'd3: 	colour <= comingSoonColour;
				5'd4: 	colour <= comingSoonSelectColour;
				5'd5: 	colour <= creditsColour;
				5'd6: 	colour <= creditsPageColour;
				5'd7: 	colour <= creditsSelectColour;
				5'd8: 	colour <= gameModesColour;
				5'd9: 	colour <= gameModesSelectColour;
				5'd10: 	colour <= gameOverColour;
				5'd11: 	colour <= museMeColour;
				5'd12: 	colour <= museMeSelectColour;
				5'd13: 	colour <= onePlayerColour;
				5'd14: 	colour <= onePlayerSelectColour;
				5'd15: 	colour <= shipColour;
				5'd16: 	colour <= ship2Colour;
				5'd17: 	colour <= stayTunedPageColour;
				5'd18: 	colour <= tieFighterColour;
				5'd19: 	colour <= titleColour;
				5'd20: 	colour <= twoPlayerColour;
				5'd21: 	colour <= twoPlayerSelectColour;
			default: 	colour <= 3'bxxx;
			endcase
		end
	end
endmodule

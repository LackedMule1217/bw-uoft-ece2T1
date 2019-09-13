// File Name: gameModeOnePlayer
// Author: Shi Jie (Barney) Wei
// Date: November 18-22, 2018

/* 
Module that runs the one-player game mode

INPUT
	A. clock						Clock
	B. moveLeft					Make ship move left
	C. moveRight				Make ship move right
	D. playAgain				Option to play again after game has ended
	E. endGame					Ends game and returns to the previous screen
	F. inFocus					Whether if this game mode is in focus
OUTPUT
	A. VGA_ADAPTER
		A.1	colour[7:0]		Colour value
		A.2	x					X position
		A.3	y					Y position
		A.4	plot				Enable plot
	B. HEX
		B.1	HEX[2-0][6:0]	Score output
		B.2	HEX4[6:0]		Current FSM state output for debugging
	C. isEndGame				Has game ended
*/
		
//`timescale 1ns / 1ns // `timescale time_unit/time_precision



module gameModeOnePlayer(input clock, moveLeft, moveRight, playAgain, endGame, inFocus,
								 output reg [8:0] x,
								 output reg [7:0] y,
								 output reg [2:0] colour,
								 output reg plot, isEndGame,
								 output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
								 output [4:0] LEDR);
	// 	CUSTOM SETTINGS (for random value generator)
	localparam
		maxMinNumObj1 = {3'd4, 3'd1},				// Range of # of type 1 object (3+1:1)
		maxMinNumObj2 = {3'd3, 3'd1},				// Range of # of type 2 object (2+1:1)
		maxMinNumObj3 = {3'd2, 3'd0},				// Range of # of type 3 object (1+1:0)
		maxNumObj1 = 3'd4,							// Max # of type 1 object allowed
		maxNumObj2 = 3'd3,							// Max # of type 2 object allowed
		maxNumObj3 = 3'd2,							// Max # of type 3 object allowed
		maxMinObjsYVel = {3'd4, 3'd1},			// Range of Y velocity of objects (3+1:1)
		maxMinObjsXLoc = {11'd301, 11'd0};		// Range of X location of generated objects (300+1:0)
	// 0) Instantiate variables
	//		0.0) NULL values
	reg NULL, ZERO;
	initial begin
		NULL = 1'bx;
		ZERO = 1'b0;
	end
	//		0.1) Module 1: FSM
	wire [20:0] cntDraw;
	wire [19:0] cntHz;
	wire [11:0] score;
	wire [10:0] xDone, yDone;
	wire [6:0] drawEraseId, cntFps;
	wire [3:0] currentState, nextState, numMaxObjDrawErase1, numMaxObjDrawErase2;
	wire [2:0] drawEraseIdTrav, numObjDrawErase, numObjDisp;
	wire [1:0] cntGen;
	wire plotDone, hasCollide, isEndGameDone, hasCollided;
	//		0.2) Module 2: Object Collision
	wire [10:0] shipX, shipY, shipB, shipH, objX, objY, objB, objH;
	wire clearObjDet;
	//		0.3) Module 3: Random Number Generator
	wire [31:0] minVal, maxVal, randVal;
	wire resetRandNumGenN;
	//		0.4) Module 4: Graphics Accessor
	wire [23:0] colourDone;
	wire [20:0] pixelId;
	wire [4:0] graphicId;
	wire clearGrapAcc;
	
	// A) Instantiate modules
	//		A.1) Instantiate FSM module
	onePlayerFsm onePlayerFsm0 (
										 // A) INPUT
										 .clock(clock),
										 .resetN(inFocus),
										 .moveLeft(moveLeft),
										 .moveRight(moveRight),
										 .playAgain(playAgain),
										 .endGame(endGame),
										 //	A.0) CUSTOM SETTINGS
										 .maxMinNumObj1(maxMinNumObj1),
										 .maxMinNumObj2(maxMinNumObj2),
										 .maxMinNumObj3(maxMinNumObj3),
										 .maxNumObj1(maxNumObj1),
										 .maxNumObj2(maxNumObj2),
										 .maxNumObj3(maxNumObj3),
										 .maxMinObjsYVel(maxMinObjsYVel),
										 .maxMinObjsXLoc(maxMinObjsXLoc),
										 //	A.1) Object Collision
										 .hasCollide(hasCollide),
										 //	A.2) Random Number Generator
										 .randVal(randVal),
										 //	A.3) Graphics Accessor
										 // B) OUTPUT
										 .plot(plotDone),
										 .cntDraw(cntDraw),
										 .cntHz(cntHz),
										 .score(score),
										 .x(xDone),
										 .y(yDone),
										 .drawEraseId(drawEraseId),
										 .cntFps(cntFps),
										 .currentState(currentState),
										 .nextState(nextState),
										 .numMaxObjDrawErase1(numMaxObjDrawErase1),
										 .numMaxObjDrawErase2(numMaxObjDrawErase2),
										 .drawEraseIdTrav(drawEraseIdTrav),
										 .numObjDrawErase(numObjDrawErase),
										 .numObjDisp(numObjDisp),
										 .cntGen(cntGen),
										 .isEndGame(isEndGameDone),
										 .hasCollided(hasCollided),
										 //	B.1) Object Collision
										 .shipX(shipX),
										 .shipY(shipY),
										 .shipB(shipB),
										 .shipH(shipH),
										 .objX(objX),
										 .objY(objY),
										 .objB(objB),
										 .objH(objH),
										 .clearObjDet(clearObjDet),
										 //	B.2) Random Number Generator
										 .minVal(minVal),
										 .maxVal(maxVal),
										 .resetRandNumGenN(resetRandNumGenN),
										 //	B.3) Graphics Accessor
										 .pixelId(pixelId),
										 .graphicId(graphicId),
										 .clearGrapAcc(clearGrapAcc));
	//		A.2) Instantiate object collision detection module
	collisionDetection onePlayerColDete0 (
													  // A) Input
													  .shipX(shipX),
													  .shipY(shipY),
													  .shipB(shipB),
													  .shipH(shipH),
													  .objX(objX),
													  .objY(objY),
													  .objB(objB),
													  .objH(objH),
													  .clock(clock),
													  .clear(clearObjDet),
													  // B) Output
													  .hasCollide(hasCollide));
	//		A.3) Instantiate random value generator module
	randomValueGenerator onePlayerRndValGen0 (
														   // A) Input
														   .minVal(minVal),
														   .maxVal(maxVal),
														   .clock(clock),
														   .resetN(resetRandNumGenN),
														   // B) Output
														   .randVal(randVal));
	//		A.4) Instantiate graphics accessor module
	graphicsAccessor onePlayerGrapAcc0 (
												   // A) INPUT
												   .pixelId(pixelId),
												   .graphicId(graphicId),
												   .clock(clock),
												   .clear(clearGrapAcc),
												   // B) OUTPUT
												   .colour(colourDone[2:0]));
	
	// B) Assign output values
	// 	B.1) Assign VGA adapter values
	always @ (*) begin
		if (!inFocus) begin
			x = {9{NULL}};
			y = {8{NULL}};
			colour = {3{NULL}};
			plot = ZERO;
			isEndGame = 1'b0;
		end
		else begin
			x = xDone[8:0];
			y = yDone[7:0];
			colour = colourDone[2:0];
			plot = plotDone;
			isEndGame = isEndGameDone;
		end
	end
	//		B.2) Assign HEX display values
	//			  B.2.1) Score
	hexDecoder H5(
					  .hexVal(currentState[3:0]), 
					  .hexSeg(HEX5)
					  );
	hexDecoder H4(
					  .hexVal(numMaxObjDrawErase1[3:0]), 
					  .hexSeg(HEX4)
					  );
	hexDecoder H3(
					  .hexVal(numMaxObjDrawErase2[3:0]), 
					  .hexSeg(HEX3)
					  );
	hexDecoder H2(
					  .hexVal(score[11:8]), 
					  .hexSeg(HEX2)
					  );
	hexDecoder H1(
					  .hexVal(score[7:4]), 
					  .hexSeg(HEX1)
					  );
	hexDecoder H0(
					  .hexVal(score[3:0]), 
					  .hexSeg(HEX0)
					  );
	//		B.3) Assign LEDR Output
	assign LEDR[4:3] = cntGen;
	assign LEDR[2] = plotDone;
	assign LEDR[1] = hasCollide;
	assign LEDR[0] = isEndGameDone;
endmodule



module onePlayerFsm (
							// A) INPUT
							input clock, resetN, moveLeft, moveRight, playAgain, endGame,
							//		A.0) CUSTOM SETTINGS
							input [5:0] maxMinNumObj1, maxMinNumObj2, maxMinNumObj3, maxMinObjsYVel,
							input [2:0] maxNumObj1, maxNumObj2, maxNumObj3,
							input [21:0] maxMinObjsXLoc,
							//		A.1) Object Collision
							input hasCollide,
							//		A.2) Random Number Generator
							input [31:0] randVal,
							//		A.3) Graphics Accessor
							//	B) OUTPUT
							output [20:0] cntDraw,
							output [19:0] cntHz,
							output [11:0] score,
							output [10:0] x, y,
							output [6:0] drawEraseId, cntFps,
							output [3:0] currentState, nextState, numMaxObjDrawErase1, numMaxObjDrawErase2,
							output [2:0] drawEraseIdTrav, numObjDrawErase, numObjDisp,
							output [1:0] cntGen,
							output plot, isEndGame, hasCollided,
							//		B.1) Object Collision
							output [10:0] shipX, shipY, shipB, shipH, objX, objY, objB, objH,
							output clearObjDet,
							//		B.1) Random Number Generator
							output [31:0] minVal, maxVal,
							output resetRandNumGenN,
							//		B.3) Graphics Accessor
							output [20:0] pixelId,
							output [4:0] graphicId,
							output clearGrapAcc);
	// 0) Declare inter-module wires
	wire idReset0, idInitialDraw1, idGenObj2, idInput3, idUpdate4, idDraw5, idErase7, idDelay6, idGameOverDraw8, idGameOver9;
	
	// A) Instantitate control module
	onePlayerControl onePlayerCtrl0 (
												// A) INPUT
												.clock(clock),
												.resetN(resetN),
												.playAgain(playAgain),
												.moveLeft(moveLeft),
												.endGame(endGame),
												.hasCollide(hasCollide),
												.drawEraseId(drawEraseId),
												.numMaxObjDrawErase1(numMaxObjDrawErase1),
												.numMaxObjDrawErase2(numMaxObjDrawErase2),
												.numObjDrawErase(numObjDrawErase),
												.numObjDisp(numObjDisp),
												//	   A.1) Object Collision
												//	   A.2) Random Number Generator
												//	   A.3) Graphics Accessor
												// B) OUTPUT
												.isEndGame(isEndGame),
												.hasCollided(hasCollided),
												.drawEraseIdTrav(drawEraseIdTrav),
												//		B.0.1) State id
												.idReset0(idReset0),
												.idInitialDraw1(idInitialDraw1),
												.idGenObj2(idGenObj2),
												.idInput3(idInput3),
												.idUpdate4(idUpdate4),
												.idDraw5(idDraw5),
												.idErase7(idErase7),
												.idDelay6(idDelay6),
												.idGameOverDraw8(idGameOverDraw8),
												.idGameOver9(idGameOver9),
												.currentState(currentState),
												.nextState(nextState),
												//		B.0.2) Counters
												.cntDraw(cntDraw),
												.cntHz(cntHz),
												.cntFps(cntFps),
												.cntGen(cntGen),
												//	   B.1) Object Collision
												//	   B.2) Random Number Generator
												.resetRandNumGenN(resetRandNumGenN),
												//	   B.3) Graphics Accessor
												.clearGrapAcc(clearGrapAcc));
	// B) Instantiate datapath module
	onePlayerDatapath onePlayerDatap0 (
												  // A) INPUT
												  .clock(clock),
												  .resetN(resetN),
												  .moveLeft(moveLeft),
												  .moveRight(moveRight),
												  .cntDraw(cntDraw),
												  .drawEraseIdTrav(drawEraseIdTrav),
												  .cntGen(cntGen),
												  //		A.0) CUSTOM SETTINGS
												  .maxMinObjsXLoc(maxMinObjsXLoc),
												  .maxMinNumObj1(maxMinNumObj1),
												  .maxMinNumObj2(maxMinNumObj2),
												  .maxMinNumObj3(maxMinNumObj3),
												  .maxNumObj1(maxNumObj1),
												  .maxNumObj2(maxNumObj2),
												  .maxNumObj3(maxNumObj3),
												  .maxMinObjsYVel(maxMinObjsYVel),
												  //	  A.0) State id
												  .idReset0(idReset0),
												  .idInitialDraw1(idInitialDraw1),
												  .idGenObj2(idGenObj2),
												  .idInput3(idInput3),
												  .idUpdate4(idUpdate4),
												  .idDraw5(idDraw5),
												  .idErase7(idErase7),
												  .idDelay6(idDelay6),
												  .idGameOverDraw8(idGameOverDraw8),
												  .idGameOver9(idGameOver9),
												  //	  A.1) Object Collision
												  //	  A.2) Random Number Generator
												  .randVal(randVal),
												  //	  A.3) Graphics Accessor
												  // B) OUTPUT
												  .plot(plot),
												  .score(score),
												  .x(x),
												  .y(y),
												  .drawEraseId(drawEraseId),
												  .numMaxObjDrawErase1(numMaxObjDrawErase1),
												  .numMaxObjDrawErase2(numMaxObjDrawErase2),
												  .numObjDrawErase(numObjDrawErase),
												  .numObjDisp(numObjDisp),
												  //	  B.1) Object Collision
												  .shipX(shipX),
												  .shipY(shipY),
												  .shipB(shipB),
												  .shipH(shipH),
												  .objX(objX),
												  .objY(objY),
												  .objB(objB),
												  .objH(objH),
												  .clearObjDet(clearObjDet),
												  //	  B.2) Random Number Generator
												  .minVal(minVal),
												  .maxVal(maxVal),
												  //	  B.3) Graphics Accessor
												  .pixelId(pixelId),
												  .graphicId(graphicId));
endmodule



module onePlayerControl (
								 // A) INPUT
								 input clock, resetN, playAgain, moveLeft, endGame, hasCollide,
								 input [6:0] drawEraseId,
								 input [3:0] numMaxObjDrawErase1, numMaxObjDrawErase2,
								 input [2:0] numObjDrawErase, numObjDisp,
								 //	   A.1) Object Collision
								 //	   A.2) Random Number Generator
								 //	   A.3) Graphics Accessor
								 // B) OUTPUT
								 output reg isEndGame, hasCollided,
								 output reg [2:0] drawEraseIdTrav,
								 //		B.0.1) State id
								 output reg idReset0, idInitialDraw1, idGenObj2, idInput3, idUpdate4, idDraw5, idErase7, idDelay6, idGameOverDraw8, idGameOver9,
								 output reg [3:0] currentState, nextState,
								 //		B.0.2) Counters
								 output reg [20:0] cntDraw,
								 output reg [19:0] cntHz,
								 output reg [6:0] cntFps,
								 output reg [1:0] cntGen,
								 //	   B.1) Object Collision
								 //	   B.2) Random Number Generator
								 output reg resetRandNumGenN,
								 //	   B.3) Graphics Accessor
								 output reg clearGrapAcc);
	// 0) Instantiate variables
	// 	0.1) Assign state values
	localparam
		RESET_0				= 4'd0,
		INITIAL_DRAW_1		= 4'd1,
		GEN_OBJ_2			= 4'd2,
		INPUT_3				= 4'd3,
		UPDATE_4				= 4'd4,
		DRAW_5				= 4'd5,
		DELAY_6				= 4'd6,
		ERASE_7				= 4'd7,
		GAME_OVER_DRAW_8	= 4'd8,
		GAME_OVER_9			= 4'd9;
	
	// 1) State table
	always @ (*) begin
		case (currentState)
			// 1,1) State 0
			RESET_0:
			begin
																						nextState = INITIAL_DRAW_1;
			end
			//	1.2) State 1
			INITIAL_DRAW_1:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;
				else if 	(numObjDrawErase != 3'd0)							nextState = INITIAL_DRAW_1;
				else																	nextState = GEN_OBJ_2;
			end
			//	1.3) State 2
			GEN_OBJ_2:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;
				else if 	(cntGen != 2'd0)										nextState = GEN_OBJ_2;
				else																	nextState = INPUT_3;
			end
			//	1.4) State 3
			INPUT_3:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;
				else																	nextState = UPDATE_4;
			end
			//	1.5) State 4
			UPDATE_4:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;
				else if 	(numMaxObjDrawErase1 != 4'd0)						nextState = UPDATE_4;		// Cycling once to determine any collision
				else																	nextState = DRAW_5;
			end
			//	1.6) State 5
			DRAW_5:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;		
				else if 	(numMaxObjDrawErase2 != 4'd0)						nextState = DRAW_5;
				else																	nextState = DELAY_6;
			end
			//	1.7) State 6
			DELAY_6:
			begin
				if 		(hasCollided == 1'b1 || endGame == 1'b1)		nextState = GAME_OVER_DRAW_8;
				else if 	(cntFps != 7'd5)										nextState = DELAY_6;
				else if	(numObjDisp == 3'd0)									nextState = GEN_OBJ_2;
				else																	nextState = ERASE_7;
			end
			//	1.8) State 7
			ERASE_7:
			begin
				if 		(endGame == 1'b1)										nextState = GAME_OVER_DRAW_8;
				else if 	(numMaxObjDrawErase1 != 4'd0)						nextState = ERASE_7;
				else																	nextState = INPUT_3;
			end
			//	1.8) State 8
			GAME_OVER_DRAW_8:
			begin
				if 		(cntDraw != 21'd13499)								nextState = GAME_OVER_DRAW_8;
				else																	nextState = GAME_OVER_9;
			end
			//	1.9) State 9
			GAME_OVER_9:
			begin
				if 		(playAgain == 1'b1)									nextState = RESET_0;
				else																	nextState = GAME_OVER_9;
			end
		default: nextState = 4'dx;
		endcase
	end
	
	// 2) Enable signals to communicate with onePlayerDatapath module
	always @ (*) begin
		// 2.1) Set default values
		idReset0 			= 1'b0;
		idInitialDraw1 	= 1'b0;
		idGenObj2 			= 1'b0;
		idInput3 			= 1'b0;
		idUpdate4 			= 1'b0;
		idDraw5 				= 1'b0;
		idDelay6 			= 1'b0;
		idErase7 			= 1'b0;
		idGameOverDraw8	= 1'b0;
		idGameOver9			= 1'b0;
		// 2.2) One-hot signals depending on current state
		case (currentState)
			RESET_0:							idReset0 			= 1'b1;
			INITIAL_DRAW_1:				idInitialDraw1 	= 1'b1;
			GEN_OBJ_2:						idGenObj2 			= 1'b1;
			INPUT_3:							idInput3 			= 1'b1;
			UPDATE_4: 						idUpdate4 			= 1'b1;
			DRAW_5:							idDraw5 				= 1'b1;
			DELAY_6:							idDelay6 			= 1'b1;
			ERASE_7:							idErase7 			= 1'b1;
			GAME_OVER_DRAW_8:				idGameOverDraw8 	= 1'b1;
			GAME_OVER_9:					idGameOver9			= 1'b1;
		endcase
	end
	
	// 3) Current state control structure
	always @ (posedge clock) begin
		// 3.0) Reset
		if			(!resetN) begin
			currentState <= RESET_0;
			resetRandNumGenN <= 1'b0;
			clearGrapAcc <= 1'b1;
			isEndGame <= 1'b0;
		end
		// 3.1) State 0
		else if	(currentState == RESET_0) begin
			cntDraw <= 21'd0;
			cntHz <= 20'd0;
			cntFps <= 7'd0;
			cntGen <= 2'd0;
			drawEraseIdTrav <= 3'd6;
			resetRandNumGenN <= 1'b1;
			clearGrapAcc <= 1'b0;
			hasCollided <= 1'b0;
		end
		// 3.2) State 1
		else if 	(currentState == INITIAL_DRAW_1) begin
			//   3.2.1) When background has been drawn
			if (numObjDrawErase == 3'd2 && cntDraw == 21'd76799) begin
				cntDraw <= 21'd0;
			end
			//	  3.2.2) When ship has been drawn, prepare to go into next state (generate object)
			else if (numObjDrawErase == 3'd1 && cntDraw == 21'd1443) begin
				cntDraw <= 21'd0;
				cntGen <= 2'd3;
			end
			//	  3.2.3) Increment cntDraw
			else if (numObjDrawErase != 3'd0) cntDraw <= cntDraw + 1'd1;
		end
		// 3.3) State 2
		else if 	(currentState == GEN_OBJ_2) begin
			if (cntGen != 2'd0)		cntGen <= cntGen - 1'd1;
			else 							cntGen <= 2'd3;
		end
		// 3.4) State 3
		else if 	(currentState == INPUT_3) begin
			// None
		end
		// 3.5) State 4
		else if 	(currentState == UPDATE_4) begin
			if (hasCollide) hasCollided <= 1'b1;
		end
		// 3.6) State 5
		// 3.8) State 7
		else if 	(currentState == DRAW_5 || currentState == ERASE_7) begin
			//	  3.6.1) Traverse through drawEraseIdTrav to draw all objects sequentially
							/*
							* drawEraseIdTrav [2:0]:
							* 		3'6		ship
							* 		3'5		object type 3_1
							* 		3'4		object type 2_2
							* 		3'3		object type 2_1
							* 		3'2		object type 1_3
							* 		3'1		object type 1_2
							* 		3'0		object type 1_1
							*
							* drawEraseId [6:0]: boolean
							*		[6]		draw/erase ship
							*		[5]		draw/erase object type 3_1
							*		[4]		draw/erase object type 2_2
							*		[3]		draw/erase object type 2_1
							*		[2]		draw/erase object type 1_3
							*		[1]		draw/erase object type 1_2
							*		[0]		draw/erase object type 1_1
							*/
			case (drawEraseIdTrav)
				//			3.6.1.1) Draw/erase asteroid
				3'd0, 3'd1, 3'd2:
				begin
					if (drawEraseId[drawEraseIdTrav] == 3'd1 && cntDraw == 21'd1444) begin
						cntDraw <= 21'd0;
						if (drawEraseIdTrav != 3'd0) 	drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
						else									drawEraseIdTrav <= 3'd7;
					end
					else if (drawEraseId[drawEraseIdTrav] != 3'd1) begin
						if (drawEraseIdTrav != 3'd0) 	drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
						else									drawEraseIdTrav <= 3'd7;
						cntDraw <= 21'd0;
					end
					else cntDraw <= cntDraw + 1'd1;
				end
				//			3.6.1.2) Draw/erase tie fighter
				3'd3, 3'd4:
				begin
					if (drawEraseId[drawEraseIdTrav] == 3'd1 && cntDraw == 21'd2500) begin
						cntDraw <= 21'd0;
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
					end
					else if (drawEraseId[drawEraseIdTrav] != 3'd1) begin
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
						cntDraw <= 21'd0;
					end
					else cntDraw <= cntDraw + 1'd1;
				end
				//			3.6.1.3) Draw/erase chicken
				3'd5:
				begin
					if (drawEraseId[drawEraseIdTrav] == 3'd1 && cntDraw == 21'd3600) begin
						cntDraw <= 21'd0;
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
					end
					else if (drawEraseId[drawEraseIdTrav] != 3'd1) begin
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
						cntDraw <= 21'd0;
					end
					else cntDraw <= cntDraw + 1'd1;
				end
				//			3.6.1.4) Draw/erase ship
				3'd6:
				begin
					if (drawEraseId[drawEraseIdTrav] == 3'd1 && cntDraw == 21'd1444) begin
						cntDraw <= 21'd0;
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
					end
					else if (drawEraseId[drawEraseIdTrav] != 3'd1) begin
						drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
						cntDraw <= 21'd0;
					end
					else cntDraw <= cntDraw + 1'd1;
				end
				//			3.6.1.4) Extra step to delay cntDraw increment by one clock cycle
				3'd7:
				begin
					drawEraseIdTrav <= drawEraseIdTrav - 1'd1;
					cntDraw <= 21'd0;
				end
			endcase
		end
		// 3.7) State 6
		else if 	(currentState == DELAY_6) begin
			if (cntHz == 20'd83333) begin 							// cntHz = 20'd83333 for 60Hz with 10x clockDelay
				cntHz <= 20'd0;
					if (cntFps != 7'd5) 	cntFps <= cntFps + 1'd1;
			end
			else	cntHz <= cntHz + 1'd1;
			if (cntFps == 7'd5) 	cntFps <= 7'd0;
		end
		// 3.9) State 8
		else if	(currentState == GAME_OVER_DRAW_8) begin
			//   3.9.1) When game over has been drawn
			if 		(cntDraw == 21'd13499) begin
				cntDraw <= 21'd0;
			end
			//	  3.9.2) Increment cntDraw
			else cntDraw <= cntDraw + 1'd1;
		end
		// 3.10) State 9
		else if	(currentState == GAME_OVER_9) begin
			//	  3.10.1) Check if player wants to exit from the One-Player game mode
			if (moveLeft) isEndGame <= 1'b1;
		end
		// 3.11) Assign next state when resetN is high (not resetting)
		if (resetN) begin
			currentState <= nextState;
		end
	end
endmodule



module onePlayerDatapath (
								  // A) INPUT
								  input clock, resetN, moveLeft, moveRight,
								  input [20:0] cntDraw,
								  input [2:0] drawEraseIdTrav,
								  input [1:0] cntGen,
								  //	  A.0.1) CUSTOM SETTINGS
								  input [21:0] maxMinObjsXLoc,
								  input [5:0] maxMinNumObj1, maxMinNumObj2, maxMinNumObj3, maxMinObjsYVel,
								  input [2:0] maxNumObj1, maxNumObj2, maxNumObj3,
								  //	  A.0.2) State id
								  input idReset0, idInitialDraw1, idGenObj2, idInput3, idUpdate4, idDraw5, idErase7, idDelay6, idGameOverDraw8, idGameOver9,
								  //	  A.1) Object Collision
								  //	  A.2) Random Number Generator
								  input [31:0] randVal,
								  //	  A.3) Graphics Accessor
								  // B) OUTPUT
								  output reg plot,
								  output reg [11:0] score,
								  output reg [10:0] x, y,
								  output reg [6:0] drawEraseId,
								  output reg [3:0] numMaxObjDrawErase1, numMaxObjDrawErase2,
								  output reg [2:0] numObjDrawErase, numObjDisp,
								  //	  B.1) Object Collision
								  output reg [10:0] shipX, shipY, shipB, shipH, objX, objY, objB, objH,
								  output reg clearObjDet,
								  //	  B.2) Random Number Generator
								  output reg [31:0] minVal, maxVal,
								  //	  B.3) Graphics Accessor
								  output reg [20:0] pixelId,
								  output reg [4:0] graphicId);
	// 0) Instantiate variables and registers
	//		0.1) Local parameter for graphic id
	localparam
		graphicsIdBackground 	= 5'd1,
		graphicsIdShip 			= 5'd15,
		graphicsIdObj1				= 5'd0,
		graphicsIdObj2 			= 5'd18,
		graphicsIdObj3 			= 5'd2,
		graphicsIdBackgroundX 	= 11'd320,
		graphicsIdShipX 			= 11'd38,
		graphicsIdObj1X			= 11'd38,
		graphicsIdObj2X 			= 11'd50,
		graphicsIdObj3X 			= 11'd60,
		graphicsIdBackgroundY 	= 11'd240,
		graphicsIdShipY 			= 11'd38,
		graphicsIdObj1Y			= 11'd38,
		graphicsIdObj2Y 			= 11'd50,
		graphicsIdObj3Y 			= 11'd60,
		graphicsIdBackgroundPx 	= 21'd76799,				// (Px - 1'b1) offset
		graphicsIdShipPx 			= 21'd1443,					// (Px - 1'b1) offset
		graphicsIdObj1Px			= 21'd1443,					// (Px - 1'b1) offset
		graphicsIdObj2Px 			= 21'd2499,					// (Px - 1'b1) offset
		graphicsIdObj3Px 			= 21'd3599;					// (Px - 1'b1) offset
	// 	0.2) Local parameter for object dimensions
	localparam
		shipBH = {11'd38, 11'd38},
		obj1BH = {11'd38, 11'd38},
		obj2BH = {11'd50, 11'd50},
		obj3BH = {11'd60, 11'd60};
		/*
		*	[21:11]	base
		*	[10:00] 	height
		*/
	//		0.3) Game Over sprite dimensions and drawn state
	localparam
		graphicsIdGameOver		= 5'd10,
		graphicsIdGameOverXLoc 	= 11'd47,
		graphicsIdGameOverYLoc 	= 11'd84,
		graphicsIdGameOverX 		= 11'd225,
		graphicsIdGameOverY 		= 11'd60;
	// 	0.4) Registers to store object location and velocity
	reg [153:0] objTempLocXY;
		/*
		* Access: [2[#ofAxis]*11[bits]*drawEraseIdTrav+10[bits-1]+(axis)*11[bits] : 2[#ofAxis]*11[bits]*drawEraseIdTrav+(axis)*11[bits]]
		* Axis: 1[Y], 0[X]
		* [153:143] ship Y location
		* [142:132] ship X location
		* [131:121] object type 3_1 Y location
		* [120:110] object type 3_1 X location
		* [109:099] object type 2_2 Y location
		* [098:088] object type 2_2 X location
		* [087:077] object type 2_1 Y location
		* [076:066] object type 2_1 X location
		* [065:055] object type 1_3 Y location
		* [054:044] object type 1_3 X location
		* [043:033] object type 1_2 Y location
		* [032:022] object type 1_2 X location
		* [021:011] object type 1_1 Y location
		* [010:000] object type 1_1 X location
		*/
	reg [20:0] objTempVelY;
		/*
		* Access: [3[bits]*drawEraseIdTrav+2[bits-1] : 3[bits]*drawEraseIdTrav]
		* [20:18] ship Y speed
		* [17:15] object type 3_1 Y speed
		* [14:12] object type 2_2 Y speed
		* [11:09] object type 2_1 Y speed
		* [08:06] object type 1_3 Y speed
		* [05:03] object type 1_2 Y speed
		* [02:00] object type 1_1 Y speed
		*/
	// 	0.5) Registers to store values from randomValueGenerator
	reg [2:0] numObj1, numObj2, numObj3;
	//		0.6) Registers to store movement values
	reg [1:0] moveShipDirTemp;
		/*
		* 2'd0	stay
		* 2'd1	move left
		* 2'd2	move right
		*/
	//		0.7) Register to store (negative) increments for each displayed object to decrement numObjDisp
	//			  Also used to update score
	reg [5:0] numObjDispInc;
		/*
		* [5] Object type 3_1
		* [4] Object type 2_2
		* [3] Object type 2_1
		* [2] Object type 1_3
		* [1] Object type 1_2
		* [0] Object type 1_1
		*/
	
	// 1) Communicate with control
	always @ (posedge clock) begin
		// 1.0|1.1) Reset | State 0
		if			(!resetN || idReset0) begin
			score 						<= 12'd0;
			drawEraseId 				<= 7'd0;
			numMaxObjDrawErase1 		<= 4'd0;
			numMaxObjDrawErase2 		<= 4'd0;
			numObjDrawErase 			<= 3'd2;
			numObjDisp 					<= 3'd0;
			plot 							<= 1'd0;
			objTempLocXY 				<= {11'd200, 11'd141, 132'd0};
			objTempVelY 				<= 21'd0;
			numObj1 						<= 3'd0;
			numObj2 						<= 3'd0;
			numObj3 						<= 3'd0;
			moveShipDirTemp 			<= 2'd0;
			numObjDispInc 				<= 6'd0;
			//			1.0.1) Object Collision
			shipX 		<= 11'd0;
			shipY 		<= 11'd0;
			shipB 		<= 11'd0;
			shipH 		<= 11'd0;
			objX 			<= 11'd0;
			objY 			<= 11'd0;
			objB 			<= 11'd0;
			objH 			<= 11'd0;
			clearObjDet <= 01'b1;
			//			1.0.2) Random Number Generator
			minVal <= 32'd0;
			maxVal <= 32'd0;
			//			1.0.3) Graphics Accessor
			pixelId 		<= 21'd0;
			graphicId 	<= 5'd0;
		end
		// 1.2) State 1
		else if 	(idInitialDraw1) begin
			//   1.2.1) Draw background
			if 		(numObjDrawErase == 3'd2) begin
				x <= cntDraw % graphicsIdBackgroundX;
				y <= cntDraw / graphicsIdBackgroundX;
				plot <= 1'd1;
				pixelId <= (y * graphicsIdBackgroundX) + x;
				graphicId <= graphicsIdBackground;
				if (cntDraw == graphicsIdBackgroundPx) 	numObjDrawErase <= numObjDrawErase - 1'd1;
			end
			//   1.2.2) Draw ship
			else if 	(numObjDrawErase == 3'd1) begin
				x <= objTempLocXY[142:132] + (cntDraw % graphicsIdShipX);
				y <= objTempLocXY[153:143] + (cntDraw / graphicsIdShipX);
				plot <= 1'd1;
				pixelId <= ((cntDraw / graphicsIdShipX) * graphicsIdShipX) + (cntDraw % graphicsIdShipX);
				graphicId <= graphicsIdShip;
				if (cntDraw == (graphicsIdShipPx)) 			numObjDrawErase <= numObjDrawErase - 1'd1;
			end
			//   1.2.3) Set plot to 1'b0;
			else if 	(numObjDrawErase == 3'd0) plot <= 1'b0;
		end
		// 1.3) State 2
		else if 	(idGenObj2) begin
			// 1.3.1) Generate number of objects of each type
			if (cntGen == 2'd3) begin
				minVal <= 32'd2147483648;
				maxVal <= 32'd4294967295;
			end
			else if (cntGen == 2'd2) begin
			// 1.3.2) Save number of objects of each type
				numObj3 <= (randVal[4:2] % (maxMinNumObj3[5:3] - maxMinNumObj3[2:0])) + maxMinNumObj3[2:0];
				numObj2 <= (randVal[3:1] % (maxMinNumObj2[5:3] - maxMinNumObj2[2:0])) + maxMinNumObj2[2:0];
				numObj1 <= (randVal[2:0] % (maxMinNumObj1[5:3] - maxMinNumObj1[2:0])) + maxMinNumObj1[2:0];
			// 1.3.3) Save Y velocity for objects of each type
				objTempVelY[17:15] <= (randVal[12:10] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
				objTempVelY[14:12] <= (randVal[11:09] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
				objTempVelY[11:09] <= (randVal[10:08] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
				objTempVelY[08:06] <= (randVal[09:07] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
				objTempVelY[05:03] <= (randVal[08:06] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
				objTempVelY[02:00] <= (randVal[07:05] % (maxMinObjsYVel[5:3] - maxMinObjsYVel[2:0])) + maxMinObjsYVel[2:0];
			// 1.3.4.1) Save X location for objects of each type
				objTempLocXY[120:110] <= (randVal[31:21] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
				objTempLocXY[098:088] <= (randVal[30:20] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
				objTempLocXY[076:066] <= (randVal[29:19] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
				objTempLocXY[054:044] <= (randVal[28:18] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
				objTempLocXY[032:022] <= (randVal[27:17] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
				objTempLocXY[010:000] <= (randVal[26:16] % (maxMinObjsXLoc[21:11] - maxMinObjsXLoc[10:0])) + maxMinObjsXLoc[10:0];
			// 1.3.4.2) Save Y location for objects of each type
				objTempLocXY[131:121] <= 11'd0;
				objTempLocXY[109:099] <= 11'd0;
				objTempLocXY[087:077] <= 11'd0;
				objTempLocXY[065:055] <= 11'd0;
				objTempLocXY[043:033] <= 11'd0;
				objTempLocXY[021:011] <= 11'd0;
			end
			// 1.3.5) Save number of objects of each type
			else if (cntGen == 2'd1) begin
				case (numObj1)
					3'd1: drawEraseId[2:0] <= 3'b001;
					3'd2: drawEraseId[2:0] <= 3'b011;
					3'd3: drawEraseId[2:0] <= 3'b111;
				default 	drawEraseId[2:0] <= 3'bxxx;
				endcase
				case (numObj2)
					3'd1: drawEraseId[4:3] <= 2'b01;
					3'd2: drawEraseId[4:3] <= 2'b11;
				default 	drawEraseId[4:3] <= 2'bxx;
				endcase
				case (numObj3)
					3'd0: drawEraseId[5] <= 1'b0;
					3'd1: drawEraseId[5] <= 1'b1;
				default 	drawEraseId[5] <= 1'bx;
				endcase
				drawEraseId[6] 		<= 1'b1;
				// "3'd1": offset from ship and (collision detection 1 clk delay + check for object exit screen)
				numMaxObjDrawErase1	<= {1'd0, maxNumObj3} + {1'd0, maxNumObj2} + {1'd0, maxNumObj1} - 4'd1;
				// "1'd2": offset from ship
				numMaxObjDrawErase2 	<= {1'd0, maxNumObj3} + {1'd0, maxNumObj2} + {1'd0, maxNumObj1} - 4'd2;
				// "1'd1": ship
				numObjDrawErase 		<= numObj1 + numObj2 + numObj3 + 1'd1;
				numObjDisp 				<= numObj1 + numObj2 + numObj3;
			end
				
		end
		// 1.4) State 3
		else if 	(idInput3) begin
			if 		(moveLeft) 	moveShipDirTemp <= 2'd1;
			else if 	(moveRight) moveShipDirTemp <= 2'd2;
			else 						moveShipDirTemp <= 2'd0;
			//	  1.4.1) Reassign numMaxObjDrawErase1
			// 			"3'd1": offset from ship and (collision detection 1 clk delay + check for object exit screen)
			numMaxObjDrawErase1	<= {1'd0, maxMinNumObj3[5:3]} + {1'd0, maxMinNumObj2[5:3]} + {1'd0, maxMinNumObj1[5:3]} - 4'd1;
			// 			"1'd2": offset from ship
			numMaxObjDrawErase2 	<= {1'd0, maxMinNumObj3[5:3]} + {1'd0, maxMinNumObj2[5:3]} + {1'd0, maxMinNumObj1[5:3]} - 4'd2;
		end
		// 1.5) State 4
		else if 	(idUpdate4) begin
			//	  1.5.1) Update ship and object locations
			if 		(numMaxObjDrawErase1 == 4'd8) begin
				// 		1.5.1.0) Decrement counter
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				// 		1.5.1.1) Update ship location based on direction while preventing ship from exiting the sides of the screen
				case (moveShipDirTemp)
					2'd1:		// Move left
					begin
						if (objTempLocXY[142:132] > 11'd4)
							objTempLocXY[142:132] <= objTempLocXY[142:132] - 3'd4;
					end
					2'd2:		// Move right
					begin
						if (objTempLocXY[142:132] < (graphicsIdBackgroundX - shipBH[21:11] - 11'd4))
							objTempLocXY[142:132] <= objTempLocXY[142:132] + 3'd4;
					end
				endcase
				// 		1.5.1.2) Update object location based on velocity
				if (drawEraseId[5]) objTempLocXY[131:121] <= objTempLocXY[131:121] + objTempVelY[17:15];
				if (drawEraseId[4]) objTempLocXY[109:099] <= objTempLocXY[109:099] + objTempVelY[14:12];
				if (drawEraseId[3]) objTempLocXY[087:077] <= objTempLocXY[087:077] + objTempVelY[11:09];
				if (drawEraseId[2]) objTempLocXY[065:055] <= objTempLocXY[065:055] + objTempVelY[08:06];
				if (drawEraseId[1]) objTempLocXY[043:033] <= objTempLocXY[043:033] + objTempVelY[05:03];
				if (drawEraseId[0]) objTempLocXY[021:011] <= objTempLocXY[021:011] + objTempVelY[02:00];
			end
			//	  1.5.2) Check collision of objects with ship
			//	  			1.5.2.1) Check collision for object type 3_1
			else if 	(numMaxObjDrawErase1 == 4'd7) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				shipX <= objTempLocXY[142:132];
				shipY <= objTempLocXY[153:143];
				shipB <= shipBH[21:11];
				shipH <= shipBH[10:00];
				objX <= objTempLocXY[120:110];
				objY <= objTempLocXY[131:121];
				objB <= obj3BH[21:11];
				objH <= obj3BH[10:00];
				clearObjDet <= 1'b0;
			end
			//	  			1.5.2.2) Check collision for object type 2_2
			else if 	(numMaxObjDrawErase1 == 4'd6) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				objX <= objTempLocXY[098:088];
				objY <= objTempLocXY[109:099];
				objB <= obj2BH[21:11];
				objH <= obj2BH[10:00];
			end
			//	  			1.5.2.3) Check collision for object type 2_1
			else if 	(numMaxObjDrawErase1 == 4'd5) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				objX <= objTempLocXY[076:066];
				objY <= objTempLocXY[087:077];
			end
			//	  			1.5.2.4) Check collision for object type 1_3
			else if 	(numMaxObjDrawErase1 == 4'd4) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				objX <= objTempLocXY[054:044];
				objY <= objTempLocXY[065:055];
				objB <= obj1BH[21:11];
				objH <= obj1BH[10:00];
			end
			//	  			1.5.2.5) Check collision for object type 1_2
			else if 	(numMaxObjDrawErase1 == 4'd3) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				objX <= objTempLocXY[032:022];
				objY <= objTempLocXY[043:033];
			end
			//	  			1.5.2.6) Check collision for object type 1_1
			else if 	(numMaxObjDrawErase1 == 4'd2) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				objX <= objTempLocXY[010:000];
				objY <= objTempLocXY[021:011];
			end
			//	  			1.5.2.7) Allow for object collision detection 1 clock cycle delay + Check for objects exiting the screen
			else if 	(numMaxObjDrawErase1 == 4'd1) begin
				numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				clearObjDet <= 1'b1;
				//						1.5.2.7.1) Object type 3_1
				if (drawEraseId[5]) begin
					if (objTempLocXY[131:121] > graphicsIdBackgroundY) begin
						drawEraseId[5] <= 1'd0;
						numObjDispInc[5] <= 1'd1;
					end
				end
				else 	numObjDispInc[5] <= 1'd0;
				//						1.5.2.7.2) Object type 2_2
				if (drawEraseId[4]) begin
					if (objTempLocXY[109:099] > graphicsIdBackgroundY) begin
						drawEraseId[4] <= 1'd0;
						numObjDispInc[4] <= 1'd1;
					end
				end
				else 	numObjDispInc[4] <= 1'd0;
				//						1.5.2.7.3) Object type 2_1
				if (drawEraseId[3]) begin
					if (objTempLocXY[087:077] > graphicsIdBackgroundY) begin
						drawEraseId[3] <= 1'd0;
						numObjDispInc[3] <= 1'd1;
					end
				end
				else 	numObjDispInc[3] <= 1'd0;
				//						1.5.2.7.4) Object type 1_3
				if (drawEraseId[2]) begin
					if (objTempLocXY[065:055] > graphicsIdBackgroundY) begin
						drawEraseId[2] <= 1'd0;
						numObjDispInc[2] <= 1'd1;
					end
				end
				else 	numObjDispInc[2] <= 1'd0;
				//						1.5.2.7.5) Object type 1_2
				if (drawEraseId[1]) begin
					if (objTempLocXY[043:033] > graphicsIdBackgroundY) begin
						drawEraseId[1] <= 1'd0;
						numObjDispInc[1] <= 1'd1;
					end
				end
				else 	numObjDispInc[1] <= 1'd0;
				//						1.5.2.7.6) Object type 1_1
				if (drawEraseId[0]) begin
					if (objTempLocXY[021:011] > graphicsIdBackgroundY) begin
						drawEraseId[0] <= 1'd0;
						numObjDispInc[0] <= 1'd1;
					end
				end
				else 	numObjDispInc[0] <= 1'd0;
			end
			//				1.5.2.8) Update numObjDisp and score and reset numObjDispInc
			//							Can place here when numMaxObjDrawErase1 == 3'd0 because numObjDisp does not
			//							affect nextState of current state
			else if 	(numMaxObjDrawErase1 == 4'd0) begin
				numObjDisp <= numObjDisp - (numObjDispInc[5] +
													 numObjDispInc[4] +
													 numObjDispInc[3] +
													 numObjDispInc[2] +
													 numObjDispInc[1] +
													 numObjDispInc[0]);
				score <= score + (numObjDispInc[5] +
										numObjDispInc[4] +
										numObjDispInc[3] +
										numObjDispInc[2] +
										numObjDispInc[1] +
										numObjDispInc[0]);
				numObjDispInc <= 6'd0;
			end
		end
		// 1.6) State 5
		else if 	(idDraw5) begin
			if 		(numMaxObjDrawErase2 == 4'd7) begin
			//	  1.6.1) Reassign numMaxObjDrawErase1
				numMaxObjDrawErase1 	<= numMaxObjDrawErase2;
			//   1.6.2) Draw ship
				x <= objTempLocXY[142:132] + (cntDraw % graphicsIdShipX);
				y <= objTempLocXY[153:143] + (cntDraw / graphicsIdShipX);
				plot <= 1'b1;
				pixelId <= ((cntDraw / graphicsIdShipX) * graphicsIdShipX) + (cntDraw % graphicsIdShipX);
				graphicId <= graphicsIdShip;
				if (cntDraw == graphicsIdShipPx) 			numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
			end
			//   1.6.3) Draw object type 3_1
			else if 	(numMaxObjDrawErase2 == 4'd6) begin
				//			1.6.3.1) Check for object existence
				if (drawEraseId[5]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[131:121] + (cntDraw / graphicsIdObj3X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[120:110] + (cntDraw % graphicsIdObj3X);
						y <= objTempLocXY[131:121] + (cntDraw / graphicsIdObj3X);
						plot <= 1'b1;
						pixelId <= ((cntDraw / graphicsIdObj3X) * graphicsIdObj3X) + (cntDraw % graphicsIdObj3X);
						graphicId <= graphicsIdObj3;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj3Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.4) Draw object type 2_2
			else if 	(numMaxObjDrawErase2 == 4'd5) begin
				//			1.6.4.1) Check for object existence
				if (drawEraseId[4]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[109:099] + (cntDraw / graphicsIdObj2X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[098:088] + (cntDraw % graphicsIdObj2X);
						y <= objTempLocXY[109:099] + (cntDraw / graphicsIdObj2X);
						plot <= 1'b1;
						pixelId <= ((cntDraw / graphicsIdObj2X) * graphicsIdObj2X) + (cntDraw % graphicsIdObj2X);
						graphicId <= graphicsIdObj2;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj2Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.5) Draw object type 2_1
			else if 	(numMaxObjDrawErase2 == 4'd4) begin
				//			1.6.5.1) Check for object existence
				if (drawEraseId[3]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[087:077] + (cntDraw / graphicsIdObj2X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[076:066] + (cntDraw % graphicsIdObj2X);
						y <= objTempLocXY[087:077] + (cntDraw / graphicsIdObj2X);
						plot <= 1'd1;
						pixelId <= ((cntDraw / graphicsIdObj2X) * graphicsIdObj2X) + (cntDraw % graphicsIdObj2X);
						graphicId <= graphicsIdObj2;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj2Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.6) Draw object type 1_3
			else if 	(numMaxObjDrawErase2 == 4'd3) begin
				//			1.6.6.1) Check for object existence
				if (drawEraseId[2]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[065:055] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[054:044] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[065:055] + (cntDraw / graphicsIdObj1X);
						plot <= 1'd1;
						pixelId <= ((cntDraw / graphicsIdObj1X) * graphicsIdObj1X) + (cntDraw % graphicsIdObj1X);
						graphicId <= graphicsIdObj1;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.7) Draw object type 1_2
			else if 	(numMaxObjDrawErase2 == 4'd2) begin
				//			1.6.7.1) Check for object existence
				if (drawEraseId[1]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[043:033] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[032:022] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[043:033] + (cntDraw / graphicsIdObj1X);
						plot <= 1'd1;
						pixelId <= ((cntDraw / graphicsIdObj1X) * graphicsIdObj1X) + (cntDraw % graphicsIdObj1X);
						graphicId <= graphicsIdObj1;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.8) Draw object type 1_1
			else if 	(numMaxObjDrawErase2 == 4'd1) begin
				//			1.6.8.1) Check for object existence
				if (drawEraseId[0]) begin
					// 				Don't draw the parts of the object that has gone off-screen
					if ((objTempLocXY[021:011] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[010:000] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[021:011] + (cntDraw / graphicsIdObj1X);
						plot <= 1'd1;
						pixelId <= ((cntDraw / graphicsIdObj1X) * graphicsIdObj1X) + (cntDraw % graphicsIdObj1X);
						graphicId <= graphicsIdObj1;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
				end
				else begin
					numMaxObjDrawErase2 <= numMaxObjDrawErase2 - 1'd1;
					plot <= 1'b0;
				end
			end
			//   1.6.9) Set plot to 1'b0;
			else if 	(numMaxObjDrawErase2 == 4'd0) plot <= 1'b0;
		end
		// 1.7) State 6
		else if 	(idDelay6) begin
			// Nothing
		end
		// 1.8) State 7
		else if 	(idErase7) begin
			if 		(numMaxObjDrawErase1 == 4'd7) begin
			//	  1.8.1) Reassign numMaxObjDrawErase2
				numMaxObjDrawErase2 <= numMaxObjDrawErase1;
			//   1.8.2) Erase ship
				x <= objTempLocXY[142:132] + (cntDraw % graphicsIdShipX);
				y <= objTempLocXY[153:143] + (cntDraw / graphicsIdShipX);
				plot <= 1'd1;
				pixelId <= (y * graphicsIdBackgroundX) + x;
				graphicId <= graphicsIdBackground;
				if (cntDraw == graphicsIdShipPx)  			numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.3) Erase object type 3_1
			else if 	(numMaxObjDrawErase1 == 4'd6) begin
				//			1.8.3.1) Check for object existence
				if (drawEraseId[5]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[131:121] + (cntDraw / graphicsIdObj3X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[120:110] + (cntDraw % graphicsIdObj3X);
						y <= objTempLocXY[131:121] + (cntDraw / graphicsIdObj3X);
						plot <= 1'd1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj3Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.4) Erase object type 2_2
			else if 	(numMaxObjDrawErase1 == 4'd5) begin
				//			1.8.4.1) Check for object existence
				if (drawEraseId[4]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[109:099] + (cntDraw / graphicsIdObj2X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[098:088] + (cntDraw % graphicsIdObj2X);
						y <= objTempLocXY[109:099] + (cntDraw / graphicsIdObj2X);
						plot <= 1'd1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj2Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.5) Erase object type 2_1
			else if 	(numMaxObjDrawErase1 == 4'd4) begin
				//			1.8.5.1) Check for object existence
				if (drawEraseId[3]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[087:077] + (cntDraw / graphicsIdObj2X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[076:066] + (cntDraw % graphicsIdObj2X);
						y <= objTempLocXY[087:077] + (cntDraw / graphicsIdObj2X);
						plot <= 1'd1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj2Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.6) Erase object type 1_3
			else if 	(numMaxObjDrawErase1 == 4'd3) begin
				//			1.8.6.1) Check for object existence
				if (drawEraseId[2]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[065:055] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[054:044] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[065:055] + (cntDraw / graphicsIdObj1X);
						plot <= 1'd1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.7) Erase object type 1_2
			else if 	(numMaxObjDrawErase1 == 4'd2) begin
				//			1.8.7.1) Check for object existence
				if (drawEraseId[1]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[043:033] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[032:022] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[043:033] + (cntDraw / graphicsIdObj1X);
						plot <= 1'd1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.8) Erase object type 1_1
			else if 	(numMaxObjDrawErase1 == 4'd1) begin
				//			1.8.8.1) Check for object existence
				if (drawEraseId[0]) begin
					// 				Don't erase the parts of the object that has gone off-screen
					if ((objTempLocXY[021:011] + (cntDraw / graphicsIdObj1X)) < graphicsIdBackgroundY) begin
						x <= objTempLocXY[010:000] + (cntDraw % graphicsIdObj1X);
						y <= objTempLocXY[021:011] + (cntDraw / graphicsIdObj1X);
						plot <= 1'b1;
						pixelId <= (y * graphicsIdBackgroundX) + x;
						graphicId <= graphicsIdBackground;
					end
					else plot <= 1'b0;
					if (cntDraw == graphicsIdObj1Px)  		numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
				end
				else 													numMaxObjDrawErase1 <= numMaxObjDrawErase1 - 1'd1;
			end
			//   1.8.9) Set plot to 1'b0;
			else if 	(numMaxObjDrawErase1 == 4'd0) plot <= 1'b0;
		end
		// 1.9) State 8
		else if 	(idGameOverDraw8) begin
			//	  1.9.1) Draw game over sprite
			x <= graphicsIdGameOverXLoc + (cntDraw % graphicsIdGameOverX);
			y <= graphicsIdGameOverYLoc + (cntDraw / graphicsIdGameOverX);
			plot <= 1'b1;
			pixelId <= ((cntDraw / graphicsIdGameOverX) * graphicsIdGameOverX) + (cntDraw % graphicsIdGameOverX);
			graphicId <= graphicsIdGameOver;
		end
		// 1.10) State 9
		else if (idGameOver9) begin
			// 	1.10.1 Set plot to 1'b0
			plot <= 1'b0;
		end
	end
endmodule

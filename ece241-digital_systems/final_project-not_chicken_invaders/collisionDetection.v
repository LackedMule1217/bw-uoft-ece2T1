// File Name: collisionDetection
// Author: Shi Jie (Barney) Wei
// Date: November 18, 2018

/* 
Function that determines whether an object has collided with the player's ship
(max resolution - 1920*1080)

INPUT
	A. Ship
		A.1 shipX[10:0]		Ship's x coordinate (northwest)
		A.2 shipY[10:0]		Ship's y coordinate (northwest)
		A.3 shipB[10:0]		Ship's length
		A.4 shipH[10:0]		Ship's height
	B. Object
		B.1 objX[10:0]			Object's x coordinate (northwest)
		B.2 objY[10:0]			Object's y coordinate (northwest)
		B.3 objB[10:0]			Object's base length
		B.4 objH[10:0]			Object's height
	C. clock						Clock
	D. clear						Synchronous clear to 0
OUTPUT
	A. hasCollide				Whether if object has colllided with ship
*/
		
`timescale 1ns / 1ns // `timescale time_unit/time_precision



module collisionDetection(input [10:0] shipX, shipY, shipB, shipH, objX, objY, objB, objH,
								  input clock, clear,
								  output hasCollide
								  );
	
	// 0) Instantiate variables
	reg hasCollideDone;
	reg [10:0] shipYBandN, shipYBandS, shipXBandW, shipXBandE, objYBandN, objYBandS, objXBandW, objXBandE;
	
	// 1) Sequential always block to update reg values
	always @ (*) begin
		shipYBandN = shipY;
		shipYBandS = shipY + shipH;
		shipXBandW = shipX;
		shipXBandE = shipX + shipB;
		objYBandN = objY;
		objYBandS = objY + objH;
		objXBandW = objX;
		objXBandE = objX + objB;
	end
	
	// 2) Combinational always block to update register values
	always @ (posedge clock) begin
		if (clear) hasCollideDone <= 1'd0;
		else if (objYBandS < shipYBandN || objYBandN > shipYBandS) hasCollideDone <= 1'd0;
		else if (objXBandE < shipXBandW || objXBandW > shipXBandE) hasCollideDone <= 1'd0;
		else hasCollideDone <= 1'd1;
	end
	
	// 2) Assign output values
	assign hasCollide = hasCollideDone;
		
endmodule

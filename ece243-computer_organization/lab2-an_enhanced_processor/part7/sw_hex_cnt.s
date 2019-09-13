.define LEDR_ADDRESS 0x1000
.define HEX0_ADDRESS 0x2000
.define HEX1_ADDRESS 0x2001
.define HEX2_ADDRESS 0x2002
.define HEX3_ADDRESS 0x2003
.define HEX4_ADDRESS 0x2004
.define HEX5_ADDRESS 0x2005
.define SW_ADDRESS 0x3000
.define ZERO 0x0000
.define ONE 0x0001
.define LIM1 0xC350							// 50000 - 0xC350
.define LIM2 0x03E8 						// 1000 - 0x03E8
.define STACK 256							// bottom of memory

// This program displays a binary counter on the LED and HEX ports
// The switches are used to control the speed of the counter
// 		r0 = counter value -> stored in stack
//		r6 = stack pointer
//		r7 = program counter (PC)
			
			mvi		r6, #STACK				// used as a stack pointer
			
			mvi 	r0, #ZERO				// counter value
			
			// Get led and switch addresses and light up LEDs
MAIN:		mvi 	r1, #LEDR_ADDRESS		// point r0 to LED port
			st		r0, [r1]				// light up LEDs
			
			// Get HEX values and light up HEXs
			mvi		r7, #SHOWHEX			// go to show HEX display subroutine
			
			// Get counter decrement value based on switch value
MAIN1:		mvi		r3, #512				// use r3 to decrement
			mvi 	r2, #SW_ADDRESS			// point r1 to SW port
			ld		r4, [r2]				// read switch values from r2 to r4
			sub		r3, r4					// get decrement value by [max_switch_value + 1 - switch_value]
			
	// A. DELAY LOOP1
    		mvi 	r1, #LIM1				// store LIM1 to r1
LOOP1:		mvi 	r2, #LIM2				// store LIM2 to r2 to count upto 50M
			mvi		r7, #LOOP2				// go to loop2
LOOP11:		sub 	r1, r3					// decrement first delay count
			mvi     r4, #LOOP1
			mvnc	r7, r4					// loop until first delay count gets to 0
			mvi 	r4, #ONE
			add 	r0, r4					// increment the counter by 1
			mvi		r7, #MAIN				// make PC point to MAIN
//-------------------------------------------------------------------------------------------------------------//
	// B. DELAY LOOP2
LOOP2:		sub		r2, r3 					// decrement second delay count
			mvi		r4, #LOOP2
			mvnc	r7, r4					// loop until second delay count gets to 0
			mvi		r7, #LOOP11					// go back to loop1

//-------------------------------------------------------------------------------------------------------------//
	// C. DISPLAY ON HEX
SHOWHEX:	mvi	r1, #ONE					// used to add/sub 1
			sub r6, r1
			st	r0, [r6]					// save counter value from r0 to stack
			
			// HEX0
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [0]
			mvi	r3, #HEX0_ADDRESS			// point to HEX0
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX0
			mv	r0, r2						// move quotient back into r0 to replace the remainder
			
			// HEX1
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [1]
			mvi	r3, #HEX1_ADDRESS			// point to HEX1
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX1
			mv	r0, r2						// move quotient back into r0 to replace the remainder
			
			// HEX2
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [2]
			mvi	r3, #HEX2_ADDRESS			// point to HEX2
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX2
			mv	r0, r2						// move quotient back into r0 to replace the remainder
			
			// HEX3
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [3]
			mvi	r3, #HEX3_ADDRESS			// point to HEX3
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX3
			mv	r0, r2						// move quotient back into r0 to replace the remainder
			
			// HEX4
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [4]
			mvi	r3, #HEX4_ADDRESS			// point to HEX4
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX4
			mv	r0, r2						// move quotient back into r0 to replace the remainder
			
			// HEX5
			mv	r5, r7						// allows base 10 subroutine to skip next line when it returns
			mvi	r7, #DIV10					// go to HEX base 10 divider [5]
			mvi	r3, #HEX5_ADDRESS			// point to HEX5
			mvi r4, #HEXDIG
			add	r4, r0						// choose HEX digit to display
			ld	r1, [r4]
			st	r1, [r3]					// display HEX5
			
			mvi r1, #ONE
			ld 	r0, [r6]					// restore counter value from stack to r0
			add	r6, r1
			mvi	r7, #MAIN1					// go to MAIN1
//-------------------------------------------------------------------------------------------------------------//
	// C.1 HEX BASE 10 DIVIDER
	//    This subroutine divides the number in r0 by 10
	// 	  The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r2
	// 	  input: r0=counter_value, r5=call_line
	// 	  returns: quotient Q in r2, remainder R in r0
DIV10:		mvi r1, #1
			mvi r2, #0 // init Q
			mvi r3, #RETDIV // for branching
			
	DLOOP:	mvi r4, #9 // check if r0 is < 10 yet
			sub r4, r0
			mvnc r7, r3 // if so, then return
			
	INC:	add r2, r1 // but if not, then increment Q
			mvi r4, #10
			sub r0, r4 // r0 -= 10
			mvi r7, #DLOOP // continue loop

	RETDIV:	add r5, r1 // adjust the return address by 2
			add r5, r1
			mv r7, r5 // return results
//-------------------------------------------------------------------------------------------------------------//
	// D. HEX BASE 10 DIGITS
HEXDIG:		.word 0b11000000			// '0'
			.word 0b11111001			// '1'
			.word 0b10100100			// '2'
			.word 0b10110000			// '3'
			.word 0b00011001			// '4'
			.word 0b00010010			// '5'
			.word 0b00000010			// '6'
			.word 0b11111000			// '7'
			.word 0b10000000			// '8'
			.word 0b10011000			// '9'
			.word 0b00001000			// 'A'
			.word 0b00000011			// 'B'
			.word 0b01000110			// 'C'
			.word 0b00100001			// 'D'
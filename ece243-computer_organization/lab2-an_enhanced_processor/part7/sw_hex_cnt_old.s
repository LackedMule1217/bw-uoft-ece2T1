.define HEX0_ADDRESS 0x2000
.define HEX1_ADDRESS 0x2001
.define HEX2_ADDRESS 0x2002
.define HEX3_ADDRESS 0x2003
.define HEX4_ADDRESS 0x2004
.define SW_ADDRESS 0x3000
.define ZERO 0x0000
.define ONE 0x0001
.define LIM1 0xC350							// 50000
.define LIM2 0x03E8 						// 1000

// This program displays a decimal counter on the HEX port
// The switches are used to control the speed of the counter
// 		r0 = counter value
//		r1 = SW_ADDRESS			||	HEXX_ADDRESS		||	#LIM1
//		r2 = HEX0_ADDRESS		||	#LIM2
//		r3 = HEX1_ADDRESS		||	decrement value 					|| 	#ONE
//		r4 = HEX2_ADDRESS		||	switch values
//		r5 = HEX3_ADDRESS		||	address of delay loop instruction
//		r6 = HEX4_ADDRESS
//		r7 = program counter (PC)

			mvi 	r0, #ZERO				// counter value
			
			// Get HEX addresses and light up HEX to 0 initially
			mvi 	r2, #HEX0_ADDRESS		// point r2 to HEX0 port
			mvi 	r3, #HEX1_ADDRESS		// point r3 to HEX1 port
			mvi 	r4, #HEX2_ADDRESS		// point r4 to HEX2 port
			mvi 	r5, #HEX3_ADDRESS		// point r5 to HEX3 port
			mvi 	r6, #HEX4_ADDRESS		// point r6 to HEX4 port
			st		r0, [r2]				// light up HEX0
			st		r0, [r3]				// light up HEX1
			st		r0, [r4]				// light up HEX2
			st		r0, [r5]				// light up HEX3
			st		r0, [r6]				// light up HEX4
			
			// Get switch address
MAIN:		mvi 	r1, #SW_ADDRESS			// point r1 to SW port
			
			// Get counter decrement value based on switch value
			mvi		r3, #512				// use r3 to decrement
			ld		r4, [r1]				// read switch values from r1 to r4
			sub		r3, r4					// get decrement value by [max_switch_value + 1 - switch_value]
			
			// Delay loop based on switch values
			mvi 	r1, #LIM1				// store LIM1 to r2
			mvi 	r2, #LIM2				// store LIM2 to r3 to count to 50M
			mv 		r5, r7					// save address of delay loop intruction
			sub 	r1, r3					// decrement first delay count
			mvnz	r7, r5					// loop until first delay count gets to 0
			mvi 	r1, #LIM1				// store LIM1 to r1
			sub		r2, r3 					// decrement second delay count
			mvnz	r7, r5					// loop until second delay count gets to 0
			mvi 	r2, #LIM2				// store LIM2 to r3 to count to 50M
			
			// Increment counter
			mvi 	r3, #ONE				// use r3 to increment
			add 	r0, r3					// increment the counter by 1
			
			// Display HEX and loop program
			// 		1) display HEX4
			mvi		r7, DIV10				// call subroutine DIV10
			mvi		r1, #HEX4_ADDRESS		// stores HEX4 address
			st		r0
			
			mvi	 	r7, #MAIN				// loop program
			
			
			
			// subroutine DIV10
			// 		This subroutine divides the number in r0 by 10
			// 		The algorithm subtracts 10 from r0 until r0 < 10, and keeps count in r2
			// 		input: r0
			// 		returns: quotient Q in r2, remainder R in r0
DIV10:		mvi r1, #1
			sub r6, r1 // save registers that are modified
			st r3, [r6]
			sub r6, r1
			st r4, [r6] // end of register saving
			mvi r2, #0 // init Q
			mvi r3, RETDIV // for branching
			
	DLOOP:	mvi r4, #9 // check if r0 is < 10 yet
			sub r4, r0
			mvnc r7, r3 // if so, then return
			
	INC:	add r2, r1 // but if not, then increment Q
			mvi r4, #10
			sub r0, r4 // r0 -= 10
			mvi r7, DLOOP // continue loop

	RETDIV:	ld r4, [r6] // restore saved regs
			add r6, r1
			ld r3, [r6] // restore the return address
			add r6, r1
			add r5, r1 // adjust the return address by 2
			add r5, r1
			mv r7, r5 // return results
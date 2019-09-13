.define LEDR_ADDRESS 0x1000
.define SW_ADDRESS 0x3000
.define ZERO 0x0000
.define ONE 0x0001
.define LIM1 0xC350							// 50000 - 0xC350
.define LIM2 0x03E8 						// 1000 - 0x03E8

// This program displays a binary counter on the LED port
// The switches are used to control the speed of the counter
// 		r0 = counter value
//		r1 = LEDR_ADDRESS		||	#LIM1
//		r2 = SW_ADDRESS			||	#LIM2
//		r3 = decrement value 	|| 	#ONE
//		r4 = temp values
//		r7 = program counter (PC)

			mvi 	r0, #ZERO				// counter value
			
			// Get led and switch addresses and light up LEDs
			mv		r6, r7					// save address of program loop intruction
MAIN:		mvi 	r1, #LEDR_ADDRESS		// point r0 to LED port
			mvi 	r2, #SW_ADDRESS			// point r1 to SW port
			st		r0, [r1]				// light up LEDs
			
			// Get counter decrement value based on switch value
			mvi		r3, #512				// use r3 to decrement
			ld		r4, [r2]				// read switch values from r2 to r4
			sub		r3, r4					// get decrement value by [max_switch_value + 1 - switch_value]
			
			// Delay loop1
    		mvi 	r1, #LIM1				// store LIM1 to r1
LOOP1:		mvi 	r2, #LIM2				// store LIM2 to r2 to count upto 50M
			mvi		r7, #LOOP2					// go to loop2
LOOP11:		sub 	r1, r3					// decrement first delay count
			mvi     r4, #LOOP1
			mvnc	r7, r4					// loop until first delay count gets to 0
			mvi 	r4, #ONE
			add 	r0, r4					// increment the counter by 1
			mvi		r7, #MAIN				// make PC point to MAIN
			
			// Delay loop2
LOOP2:		sub		r2, r3 					// decrement second delay count
			mvi		r4, #LOOP2
			mvnc	r7, r4					// loop until second delay count gets to 0
			mvi		r7, #LOOP11				// go back to loop1
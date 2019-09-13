/* 	Program that uses KEYs to control the increment/decrement of the first HEX digit
 	KEY0: set HEX0 to 0
	KEY1: increment HEX0 value
	KEY2: decrement HEX0 value
	KEY3: blank HEX0 value
*/

			.text 						// executable code follows
			.global _start
			.equ	HEX_ADDR, 0xFF200020	// stores HEX[3:0] mem address
			.equ	KEY_ADDR, 0xFF200050	// stores KEYs mem address
			
_start:
			LDR		R4, =HEX			// set pointer to beginning of HEX array
			ADD		R11, R4, #15		// set pointer to end of HEX array
			LDR		R5, =HEX_ADDR		// stores hex address in R5
			LDR		R6, =KEY_ADDR		// stores key address in R6
			MOV		R7,	#0				// stores key toggle state; hex will only be affected when key is depressed
loop:		LDR		R8, [R6]			// load key values into R8
			MOVS	R8, R8				// set flags
			MOVGT	R7, #1				// set key toggle to true if keys are pressed
			MOVGT	R9, R8				// copy key values to R9 if keys are pressed
			BGT		loop				// loop until key is depressed
			CMPEQ	R7, #0
			BEQ		loop				// loop until a key is pressed
										// case statement: keys have been depressed; check key value and show hex
key0:		CMP		R9, #0b1			// KEY0 has depressed; set HEX0 to 0
			BNE		key1
			LDRB	R4, =HEX			// reset pointer to beginning of HEX array
			LDRB	R10, [R4]
			STR		R10, [R5]			// set HEX0 to 0
			B		loop_end			// loop until a key is pressed
			
key1:		CMP		R9, #0b10			// KEY1 has depressed; increment HEX0 value
			BNE		key2
			CMP		R4, R11				// if reached end of HEX array, reset
			LDREQB	R4, =HEX
			LDREQB	R10, [R4]
			LDRNEB	R10, [R4, #1]!
			STR		R10, [R5]			// set HEX0 to 0
			B		loop_end			// loop until a key is pressed
			
key2:		CMP		R9, #0b100			// KEY2 has depressed; decrement HEX0 value
			BNE		key3
			CMP		R4, #HEX			// if reached the beginning of array, reset to end
			MOVEQ	R4, R11
			LDREQB	R10, [R4]!
			LDRNEB	R10, [R4, #-1]!
			STR		R10, [R5]			// set HEX0 to 0
			B		loop_end			// loop until a key is pressed
			
										// KEY3 has depressed; blank HEX0 value
key3:		LDRB	R4, =HEX_BLANK		// reset pointer to beginning of HEX array
			LDRB	R10, [R4], #4
			STR		R10, [R5]			// set HEX0 to 0
										// loop until a key is pressed
			
loop_end:	MOV		R7,	#0				// reset key toggle state
			B		loop				// default case: loop 
 
/* 	DATA	*/
HEX_BLANK:	.byte	0x0					// blank
			.skip	3
HEX: 		.byte 	0x3F				// 0
			.byte 	0x06				// 1
			.byte 	0x5B				// 2
			.byte 	0x4F				// 3
			.byte 	0x66				// 4
			.byte 	0x6D				// 5
			.byte 	0x7D				// 6
			.byte 	0x07				// 7
			.byte 	0x7F				// 8
			.byte 	0x67				// 9
			.byte 	0x77				// 10
			.byte 	0x7C				// 11
			.byte 	0x39				// 12
			.byte 	0x5E				// 13
			.byte 	0x79				// 14
			.byte 	0x71				// 15

			.end
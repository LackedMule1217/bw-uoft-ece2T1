/* 	Program that displays the clock SS:ff
		-> counter stops when any KEY is pressed
*/

			.text 							// executable code follows
			.global _start
			.equ	HEX_ADDR, 0xFF200020	// stores HEX[3:0] mem address
			.equ	KEY_ADDR, 0xFF200050	// stores KEYs mem address
			.equ	PTIM_ADDR, 0xFFFEC600	// stores address of private timer
			.equ	COUNT, 2000000			// private timer to 10M
			.equ	SCALE, 0				// private timer scale
			
_start:
			LDR		R0, =0x3F3F			// set initial HEX display to 00
			LDR		R4, =HEX			// set pointer to beginning of HEX array
			LDR		R5, =HEX_ADDR		// stores hex address
			LDR		R6, =KEY_ADDR		// stores key address
			MOV		R7,	#0				// stores counter value
			LDR		R8, =PTIM_ADDR		// stores private timer address
			LDR		R9, =COUNT			// stores count
			STR		R9, [R8]			// stores count in load value of private timer
			MOV		R9, #SCALE			// store prescaler value
			LSL		R9, R9, #8
			ADD		R9, #0b011			// store IAE for control
			STR		R9, [R8, #0x8]		// store control in private timer and enable it
			
main:		STR		R0, [R5]			// store value to HEX display
check_tim:	LDR		R9, [R8, #0xC]		// store timer timeout state
			CMP		R9, #1				// check if timer has finished the 0.25 second delay
			BNE		check_tim			// if timer has not finished, poll again
			STR		R9, [R8, #0xC]		// reset timer timeout flag
			LDR		R9, [R6, #0xC]		// if keys are pressed, pause
			LSL		R9, #28
			CMP		R9, #0
			BEQ		incre
			MOV		R10, #0b1111
			STR		R10, [R6, #0xC]		// reset key edgecapture register
check_key:	LDR		R10, [R6, #0xC]
			LSL		R10, #28
			CMP		R10, #0
			BEQ		check_key
			MOV		R10, #0b1111
			STR		R10, [R6, #0xC]		// reset key edgecapture register
incre:		ADD		R7, #1				// increment counter value
			LDR		R9, =6000			// if cnt==6000, reset counter to 0 and return to main
			CMP		R7, R9				
			MOVEQ	R7, #0
			MOV		R2, R7				// subroutine prep: moves count value to R2
			BL		HEX_DIVIDE			// calls hex divide subroutine
			MOV		R9, R0				// stores remainder [0]
			MOV		R2, R1				// stores quotient to be fed to HEX_DIVIDE again
			BL		HEX_DIVIDE			// calls hex divide subroutine
			MOV		R10, R0				// stores remainder [1]
			MOV		R2, R1				// stores quotient to be fed to HEX_DIVIDE again
			BL		HEX_DIVIDE			// calls hex divide subroutine
			MOV		R11, R0				// stores remainder [2]
			MOV		R12, R1				// stores quotient [3]
			BL		NUM_TO_HEX			// calls num to hex subroutine
			B		main				// loop to main

			
			
/* Subroutine to separate and output a number into 2 digits
 * Performs callee-save
 * Input: 		R2 - input data
 * Usage:		R4 - temporary quotient
 * Output: 		R0 - remainder
 *				R1 - quotient
 */
HEX_DIVIDE: PUSH	{R4-R12}
			MOV 	R4, #0
CONT: 		CMP 	R2, #10
			BLT 	DIV_END
			SUB 	R2, #10
			ADD 	R4, #1
			B 		CONT
DIV_END: 	MOV 	R1, R4 				// quotient in R1
			MOV		R0, R2				// remainder in R0
			POP		{R4-R12}
			BX		LR
			
			
			
 /* Subroutine to convert digits into hex encoding
 * Performs callee-save
 * Input: 		R9 - SS:ff[0]
				R10 - SS:ff[1]
				R11 - SS:ff[2]
				R12 - SS:ff[3]
 * Usage:		R4 - HEX memory value
				R5 - temporary remainder hex code
 * Output: 		R0 - hex code
 */
NUM_TO_HEX: PUSH	{R4-R12}
			LDR		R4, =HEX
			LDRB	R0, [R4, R12]		// store SS:ff[3]
			LSL		R0, R0, #8
			LDRB	R5, [R4, R11]		// store SS:ff[2]
			ADD		R0, R5
			LSL		R0, R0, #8
			LDRB	R5, [R4, R10]		// store SS:ff[1]
			ADD		R0, R5
			LSL		R0, R0, #8
			LDRB	R5, [R4, R9]		// store SS:ff[0]
			ADD		R0, R5
			POP		{R4-R12}
			BX		LR
 
 
 
/* 	DATA	*/
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

			.end
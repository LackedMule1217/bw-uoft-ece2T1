/* 	Program that auto-increments of the first two HEX digits in 0.25-second intervals
		-> counter stops when any KEY is pressed
*/

			.text 						// executable code follows
			.global _start
			.equ	HEX_ADDR, 0xFF200020	// stores HEX[3:0] mem address
			.equ	KEY_ADDR, 0xFF200050	// stores KEYs mem address
			
_start:
			LDR		R0, =0x3F3F			// set initial HEX display to 00
			LDR		R4, =HEX			// set pointer to beginning of HEX array
			LDR		R5, =HEX_ADDR		// stores hex address in R5
			LDR		R6, =KEY_ADDR		// stores key address in R6
			MOV		R7,	#0				// stores counter value
			
main:		STR		R0, [R5]			// store value to HEX display
delay:		LDR		R8, =1250000		// store delay counter and do delay
delay_1:	SUBS	R8, R8, #1
			BNE		delay_1
			LDR		R9, [R6, #0xC]		// if keys are pressed, pause
			CMP		R9, #0
			BEQ		incre
check_key:	LDR		R10, [R6]
			CMP		R10, #0
			BNE		check_key
			MOV		R10, #0b1111
			STR		R10, [R6, #0xC]		// reset key edgecapture register
incre:		ADD		R7, #1				// increment counter value
			CMP		R7, #100			// if cnt==100, reset counter to 0 and return to main
			MOVEQ	R7, #0
			MOV		R2, R7				// subroutine prep: moves count value to R2
			BL		HEX_DIVIDE			// calls hex divide subroutine
			MOV		R3, R1				// subroutine prep: moves quotient value to R3
			MOV		R2, R0				// subroutine prep: moves remainder value to R2
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
 * Input: 		R2 - remainder
				R3 - quotient
 * Usage:		R4 - HEX memory value
				R5 - temporary remainder hex code
 * Output: 		R0 - hex code
 */
NUM_TO_HEX: PUSH	{R4-R12}
			LDR		R4, =HEX
			LDRB	R0, [R4, R3]
			LSL		R0, R0, #8
			LDRB	R5, [R4, R2]
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
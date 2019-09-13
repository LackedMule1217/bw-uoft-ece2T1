/* Program that stores the maximum consecutive 1’s of elements in an array and stores into R5*/

			.text 						// executable code follows
			.global _start
			
_start:
			MOV 	R3, #TEST_NUM 		// load the memory address of the data word array
			MOV		R5, #0				// initially sets the result to 0
			MOV		R6, #0				// initially sets the result to 0
			MOV		R7, #0				// initially sets the result to 0
LOOP:		LDR 	R1, [R3], #4		// copies the data word array element and then increment address
			CMP		R1, #0				// checks if reached end of array
			BEQ		DISPLAY
			BL		ONES				// calls ONES subroutine
			CMP		R5, R0				// compares if current largest 1s > R0
			MOVLT	R5, R0				// stores R0 into R5 if current largest 1s < R0
			BL		ZEROS				// calls ONES subroutine
			CMP		R6, R0				// compares if current largest 1s > R0
			MOVLT	R6, R0				// stores R0 into R5 if current largest 1s < R0
			BL		ALTERN				// calls ALTERN (ALTERNATE) subroutine
			CMP		R7, R0				// compares if current largest 1s > R0
			MOVLT	R7, R0				// stores R0 into R5 if current largest 1s < R0
			
			B		LOOP
			
// Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
			MOV		R9,	#HEX3_0
			// stores R5
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R2, R1          // store tens digit to R2
			MOV     R1, R0          // store ones digit to R1
            BL      SEG7_CODE
			STRB	R0, [R9], #1	// load ones digit to HEX0
			MOV		R0, R2			// store tens digit to R0
			BL      SEG7_CODE
			STRB	R0, [R9], #1	// load tens digit to HEX1
			// stores R6
            MOV     R0, R6          // display R6 on HEX1-2
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R2, R1          // store tens digit to R2
			MOV     R1, R0          // store ones digit to R1
            BL      SEG7_CODE
			STRB	R0, [R9], #1	// load ones digit to HEX0
			MOV		R0, R2			// store tens digit to R0
			BL      SEG7_CODE
			STRB	R0, [R9], #1	// load tens digit to HEX1
			//	load to HEX3-0
			MOV		R9,	#HEX3_0
			LDR		R9, [R9]
			STR		R9, [R8]		// load digits to HEX3-0
			
			LDR     R8, =0xFF200030 // base address of HEX3-HEX0
			MOV		R9,	#HEX5_4
			// stores R7
            MOV     R0, R7          // display R6 on HEX1-2
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R2, R1          // store tens digit to R2
			MOV     R1, R0          // store ones digit to R1
            BL      SEG7_CODE
			STRB	R0, [R9], #1	// load ones digit to HEX0
			MOV		R0, R2			// store tens digit to R0
			BL      SEG7_CODE
			STRB	R0, [R9], #1	// load tens digit to HEX1
			//	load to HEX5-4
			MOV		R9,	#HEX5_4
			LDR		R9, [R9]
			STR		R9, [R8]		// load digits to HEX3-0
			
			B		END
			

HEX3_0:		.space	4
HEX5_4:		.space	2
			.skip	2

END: 		B 		END

			
			
/* Subroutine to calculate the number of consecutive 1s
 * Performs callee-save
 * Input: 		R1 - input data
 * Usage:		R2 - stores: LSR of input data || LSR of input data AND input data
 * Output: 		R0 - result: number of consecutive 1s
 */
ONES:		PUSH	{R1-R12, LR}		// callee-save to stack
			MOV		R0, #0
			
ONES_LOOP:	CMP		R1, #0				// loop until the data contains no more 1's
			BEQ		ONES_END
			ADD		R0, #1				// increment the number of ones counter
			LSR		R2, R1, #1			// logical shift right the input data by 1 unit and store in R2
			AND		R1, R1, R2			// bitwise and input data with LSR data and store in R2
			B		ONES_LOOP
			
ONES_END:	POP		{R1-R12, LR}		// callee-retrieve from stack
			BX		LR					// return to caller	
			

/* Subroutine to calculate the number of consecutive 0s
 * Performs callee-save
 * Input: 		R1 - input data
 * Output: 		R0 - result: number of consecutive 1s
 */
ZEROS:		PUSH	{R1-R12, LR}		// callee-save to stack

			MVN		R1, R1				// bitwise negate input data and store in R1
			BL		ONES				// call ONES subroutine to count the number of ones and store to R0
			
			POP		{R1-R12, LR}		// callee-retrieve from stack
			BX		LR					// return to caller	
			
			
/* Subroutine to calculate the number of consecutive 1,0s
 * Performs callee-save
 * Input: 		R1 - input data
 * Usage:		R2 - stores: LSR of input data || LSR of input data AND input data
 * Output: 		R0 - result: number of consecutive 1s
 */
ALTERN:		PUSH	{R1-R12, LR}		// callee-save to stack
			
			ASR		R2, R1, #1			// arithmetic shift right the input data by 1 unit and store in R2
			EOR		R1, R1, R2			// xor input data with LSR data and store in R1
			BL		ONES				// call ONES subroutine to count the number of ones and store to R0
			
			POP		{R1-R12, LR}		// callee-retrieve from stack
			BX		LR					// return to caller	
			

/* Subroutine that stores 7-seg code
 * Performs callee-save
 * Input: 		R0 - digit
 * Usage:		R1 - stores: BIT_CODES
 * Output: 		R0 - HEX BIT_CODES memory location
 */
SEG7_CODE:  PUSH	{R1-R12, LR}
			MOV     R1, #BIT_CODES  
            LDRB    R0, [R1, R0]
			POP		{R1-R12, LR}
            BX      LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      				// pad with 2 bytes to maintain word alignment

			
/* Subroutine that divides a 2 digit number into 2 separate digits
 * Performs callee-save
 * Input: 		R0 - input data
 * Usage:		R2 - stores: quotient
 * Output: 		R0 - remainder
				R1 - quotient
 */
DIVIDE: 	PUSH	{R2-R12, LR}
			MOV 	R2, #0
CONT: 		CMP 	R0, #10
			BLT 	DIV_END
			SUB 	R0, #10
			ADD 	R2, #1
			B 		CONT
			
DIV_END: 	MOV 	R1, R2 				// quotient in R1 (remainder in R0)
			POP		{R2-R12, LR}
			BX		LR
 

TEST_NUM: 	.word 	0x103fe00f			// 1) 	9 	|| 9	|| 2
			.word	0x01234567			// 2) 	3 	|| 7	|| 5
			.word	0x12345678			// 3) 	4 	|| 3	|| 5
			.word	0x23456879			// 4) 	4 	|| 4	|| 5
			.word	0x3456789a			// 5) 	4 	|| 3	|| 5
			.word	0x456789ab			// 6) 	4 	|| 3	|| 6
			.word	0x56789abc			// 7) 	4 	|| 3	|| 6
			.word	0x6789abcd			// 8) 	4 	|| 3	|| 6
			.word	0x789abcde			// 9) 	4 	|| 3	|| 6
			.word	0x89abcdef			// 9) 	4 	|| 3	|| 6
			.word	0xffffffff			// 10) 	32 	|| 0	|| 0
			.word	0x0					// 0-terminated array

			.end
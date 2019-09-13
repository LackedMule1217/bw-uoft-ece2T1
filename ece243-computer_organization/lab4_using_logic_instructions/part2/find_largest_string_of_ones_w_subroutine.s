/* Program that stores the maximum consecutive 1’s of elements in an array and stores into R5*/

			.text 						// executable code follows
			.global _start
			
_start:
			MOV 	R3, #TEST_NUM 		// load the memory address of the data word array
			MOV		R5, #0				// initially sets the result to 0
LOOP:		LDR 	R1, [R3], #4		// copies the data word array element and then increment address
			CMP		R1, #0				// checks if reached end of array
			BEQ		END
			BL		ONES				// calls ONES subroutine
			CMP		R5, R0				// compares if current largest 1s > R0
			MOVLT	R5, R0				// stores R0 into R5 if current largest 1s < R0
			B		LOOP

END: 		B 		END


/* Subroutine to calculate the number of consecutive 1s
 * Performs callee-save
 * Input: 		R1 - input data
 * Usage:		R2 - stores: LSR of input data || LSR of input data AND input data
 * Output: 		R0 - result: number of consecutive 1s
 */
ONES:		PUSH	{R1-R12}			// callee-save to stack
			MOV		R0, #0
			
ONES_LOOP:	CMP		R1, #0				// loop until the data contains no more 1's
			BEQ		ONES_END
			ADD		R0, #1				// increment the number of ones counter
			LSR		R2, R1, #1			// logical shift right the input data and store in R2
			AND		R1, R1, R2			// bitwise and input data with LSR data and store in R2
			B		ONES_LOOP
			
ONES_END:	POP		{R1-R12}			// callee-retrieve from stack
			BX		LR					// return to caller		
 

TEST_NUM: 	.word 	0x103fe00f			// 1) 9
			.word	0x01234567			// 2) 3
			.word	0x12345678			// 3) 4
			.word	0x23456879			// 4) 4
			.word	0x3456789a			// 5) 4
			.word	0x456789ab			// 6) 4
			.word	0x56789abc			// 7) 4
			.word	0x6789abcd			// 8) 4
			.word	0x789abcde			// 9) 4
			.word	0x89abcdef			// 9) 4
			.word	0xffffffff			// 10) 32
			.word	0x0					// 0-terminated array

			.end
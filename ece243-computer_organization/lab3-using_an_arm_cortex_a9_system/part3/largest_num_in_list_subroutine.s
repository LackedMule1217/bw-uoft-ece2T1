/* Program that finds the largest number in a list of integers */

			.text						// executable code follows
			.global _start

_start:
			MOV		R4, #RESULT			// R4 points to result location
			LDR		R0, [R4, #4]		// R0 holds the number of elements in the list
			BEQ		END					// end if the initial list has size of 0
			MOV		R1, #NUMBERS		// R1 points to the start of the list
			BL		LARGE
			STR		R0, [R4]			// R0 holds the subroutine return value
			
END:		B		END


/* Subrouting to find the largest integer in a list
 * Parameters: R0 has the number of elements in the list
 *			   R1 has the address of the start of the list
 * Variables: R2 - current largest number
 *			  R3 - current number
 * Returns: R0 returns the largest item in the list
 */
LARGE:		
			LDR		R2, [R1]			// R2 holds the largest number so far
LARGE1:		SUBS	R0, #1				// decrement the loop counter
			BEQ		LARGE_R				// if result is equal to 0, calls method to return from subroutine
			ADD		R1, #4				// points to the next element in the list
			LDR 	R3, [R1] 			// get the next number
			CMP		R2, R3				// compare the current largest number with the new number
			BGE		LARGE1
			MOV		R2, R3				// update the largest number
			B		LARGE1
LARGE_R:	MOV		R0, R2				// moves the current largest number from R2 to R0
			MOV		PC, LR				// return to caller

			
RESULT:		.word	0
N:			.word	7
NUMBERS:	.word	4, 5, 3, 6			// number of entries in the list
			.word	1, 8, 2				// the data
			
			.end
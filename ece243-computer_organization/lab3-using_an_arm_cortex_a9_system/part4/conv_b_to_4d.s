/* Program that converts a binary number to a 4-digit decimal using any divisor */

			.text 						// executable code follows
			.global _start
			
_start:
			MOV 	R4, #N
			LDR 	R0, [R4] 			// R0 holds N; parameter for DIVIDE goes in R0
			MOV		R1, #10				// set divisor to 10
			BL 		DIVIDE
			MOV 	R5, #Digits			// R5 points to the first entry of the digits array
			MOV		R1, #4				// stores the number of digits
POPSTACK:	SUBS	R1, #1				// decrement counter
			BLT		END					// end program if decrement counter becomes negative
			LDRB	R2, [SP], #4		// loads the byte digit from the stack
			STRB 	R2, [R5], #1 		// stores the digit to Digits
			B		POPSTACK
END: 		B 		END


/* Subroutine to perform the integer division R0 / 10.
 * Parameters: 	R0 - binary number / divident -> remainder
				R1 - divisor
 * Variables:	R2 - quotient
				R4 - number of digits to show (4 in this case)
 * Returns: stores each digit in the stack with the LSB on the top of the stack
 */
DIVIDE:		MOV		R4, #4				// stores the number of digits
DIVIDE1:	MOV 	R2, #0				// set the quotient to 0
			SUBS	R4, #1				// decrement digit counter
			BLT		DIV_END				// end subroutine if counter becomes negative
DIVIDE2:	CMP 	R0, R1				// compares the value between the binary digit and the divisor value
			SUBGE	R0, R1				// if binary digit >= divisor, subtract the two
			ADDGE	R2, #1				// add 1 to the quotient
			BGE		DIVIDE2
			STRB	R0, [SP, #-4]!		// if binary digit < divisor, push binary digit to stack
			MOV		R0, R2				// set binary digit to 0
			B		DIVIDE1				// move to the next digit
DIV_END:	BX 		LR

N: 			.word 9876 					// the decimal number to be converted
Digits: 	.space 4 					// storage space for the decimal digits
			
			.end
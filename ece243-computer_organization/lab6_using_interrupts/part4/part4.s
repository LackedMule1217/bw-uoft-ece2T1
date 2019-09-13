/* 	
	Main program that counts on LEDs with toggle mode and speed adjustments by pushbuttons.
	Program also shows time in seconds and milliseconds with toggle mode by pushbuttons.
*/

			.section .vectors, "ax"
			
			B		_start					// reset vector
			B		SERVICE_UND				// undefined instruction vector
			B		SERVICE_SVC				// software interrupt vector
			B		SERVICE_ABT_INST		// aborted prefetch vector
			B		SERVICE_ABT_DATA		// aborted data vector
			.word	0						// unused vector
			B		SERVICE_IRQ				// IRQ interrupt vector
			B		SERVICE_FIQ				// FIQ interrupt vector
		
			.text
			.global _start
			.equ	CPUIF_ADDR, 0xFFFEC100	// CPU interface base mem address
			.equ	ICDISER_ADDR, 0xFFFED100// ICDISERn base mem address
			.equ	ICDIPTR_ADDR, 0xFFFED800// ICDIPTRn base mem address
			.equ	ICDDCR_ADDR, 0xFFFED000	// ICDDCR base mem address
			.equ	PTIMER_ADDR, 0xFFFEC600	// private timer base mem address
			.equ	ITIMER_ADDR, 0xFF202000	// interval timer base mem address
			.equ	KEY_ADDR, 0xFF200050	// pushbutton KEYs base mem address
			.equ	LEDR_ADDR, 0xFF200000	// LEDR base mem address
			.equ	HEX_ADDR, 0xFF200020	// HEX base mem address

			
			
_start:
// 1) Set up stack pointers for IRQ and SVC processor modes
			MOV		R1, #0b11010010			// IRQ mode: interrupts disabled
			MSR		CPSR, R1				// write to CPSR
			LDR		SP, =0xFFFFFFFC			// set IRQ stack pointer
			MOV		R1, #0b11010011			// SVC mode: interrupts disabled
			MSR		CPSR, R1				// write to CPSR
			LDR		SP, =0x3FFFFFFC			// set SVC stack pointer
			
// 2) Configure hardware by calling subroutines
			BL		CONFIG_GIC				// configure the ARM generic interrupt controller
			BL		CONFIG_PTIMER			// configure the Private Timer
			BL		CONFIG_ITIMER			// configure the Interval Timer
			BL		CONFIG_KEYS				// configure the pushbutton KEYs port

// 3) Enable IRQ interrupts in the ARM processor
			MOV		R0, #0b01010011			// enable IRQ, MODE = SVC
			MSR		CPSR, R0

// 4) Continously show value of COUNT in LEDs
LOOP:		// write to the LEDR
			LDR		R3, =LEDR_ADDR
			LDR		R5, COUNT
			STR		R5, [R3]
			
			// write to the HEX
			LDR		R3, =HEX_ADDR
			LDR		R5, TIME
			LDR		R9, =6000				// if cnt==6000, reset counter to 0 and return to main
			CMP		R5, R9				
			MOVEQ	R5, #0
			STR		R5, TIME
			MOV		R2, R5					// subroutine prep: moves count value to R2
			BL		HEX_DIVIDE				// calls hex divide subroutine
			MOV		R9, R0					// stores remainder [0]
			MOV		R2, R1					// stores quotient to be fed to HEX_DIVIDE again
			BL		HEX_DIVIDE				// calls hex divide subroutine
			MOV		R10, R0					// stores remainder [1]
			MOV		R2, R1					// stores quotient to be fed to HEX_DIVIDE again
			BL		HEX_DIVIDE				// calls hex divide subroutine
			MOV		R11, R0					// stores remainder [2]
			MOV		R12, R1					// stores quotient [3]
			BL		NUM_TO_HEX				// calls num to hex subroutine
			LDR		R5, HEX_code
			STR		R5, [R3]
			B		LOOP



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
			
			
			
 /* Subroutine to convert digits into hex encoding and store into HEX_code
 * Performs callee-save
 * Input: 		R9 - SS:ff[0]
				R10 - SS:ff[1]
				R11 - SS:ff[2]
				R12 - SS:ff[3]
 * Usage:		R4 - HEX code
				R5 - HEX memory value
				R6 - temporary remainder hex code
 * Output:
 */
NUM_TO_HEX: PUSH	{R4-R12}
			LDR		R5, =HEX
			LDRB	R4, [R5, R12]		// store SS:ff[3]
			LSL		R4, R4, #8
			LDRB	R6, [R5, R11]		// store SS:ff[2]
			ADD		R4, R6
			LSL		R4, R4, #8
			LDRB	R6, [R5, R10]		// store SS:ff[1]
			ADD		R4, R6
			LSL		R4, R4, #8
			LDRB	R6, [R5, R9]		// store SS:ff[0]
			ADD		R4, R6
			STR		R4, HEX_code		// store HEX code
			POP		{R4-R12}
			BX		LR
 
 

/* A. Configure Hardware */
//		A.1 Configure GIC
CONFIG_GIC:	LDR		R0, =ICDISER_ADDR		// ICDISERn: set enable register
			LDR		R1, =0b1				// set interrupt enable for: private timer (ID=29), interval timer (ID=72), KEYs (ID=73)
			LSL		R1, R1, #29
			STR		R1, [R0]
			LDR		R1, =0b11
			LSL		R1, R1, #8
			STR		R1, [R0, #0x8]
			LDR		R0, =ICDIPTR_ADDR		// ICDIPTRn: processor targets register
			LDR		R1, =0b1				// set cpu0 for: private timer (ID=29), interval timer (ID=72), KEYs (ID=73)
			LSL		R1, R1, #8
			STR		R1, [R0, #0x1C]
			LDR		R1, =0b100000001
			STR		R1, [R0, #0x48]
			LDR		R0, =ICDDCR_ADDR		// Enable ICDDCR to allow interrupts to be forwarded to CPU interface
			MOV		R1, #0x1
			STR		R1, [R0]
			LDR		R0, =CPUIF_ADDR			// enable interrupts of all priorities in CPU interface
			LDR		R1, =0xFF
			STR		R1, [R0, #4]
			MOV		R1, #0x1				// enable ICCICR to allow interrupts to be forwarded to CPU
			STR		R1, [R0]
			BX		LR

//		A.2 Configure the Private Timer
CONFIG_PTIMER:
			LDR		R0, =PTIMER_ADDR		// private timer key base address
			LDR		R1, =0x1E8480			// store 2M of count for 0.01 seconds (200 MHz)
			STR		R1, [R0]
			MOV		R1, #0b111				// enable private timer with auto and interrupt
			STR		R1, [R0, #0x8]			// interrupt mask register (base + 8)
			BX		LR
			
//		A.3 Configure the Interval Timer
CONFIG_ITIMER:
			LDR		R0, =ITIMER_ADDR		// interval timer key base address
			LDR		R1, =0x017D7840			// store 50M of count for 0.25 seconds (100 MHz)
			STR		R1, [R0, #0x8]			// store LSB of counter start value
			LSR		R1, R1, #16
			STR		R1, [R0, #0xC]			// store MSB of counter start value		
			LDR		R1, =0b0111				// enable interval timer with interrupt
			STR		R1, [R0, #0x4]			// interrupt mask register (base + 8)
			BX		LR
			
//		A.4 Configure KEY pushbuttons
CONFIG_KEYS:
			LDR		R0, =KEY_ADDR			// pushbutton key base address
			MOV		R1, #0xF				// enable interrupts for all 4 KEYs
			STR		R1, [R0, #0x8]			// interrupt mask register (base + 8)
			BX		LR
			
			

/* B. Define the exception service routines */
//		B.1 IRQ
SERVICE_IRQ:
			PUSH	{R0-R12, LR}
			LDR		R4, =CPUIF_ADDR			// GIC CPU interface base address
			LDR		R5, [R4, #0xC]			// read the ICCIAR in the CPU interface
			
irq_1:		CMP		R5, #29					// check if interrupted by private timer
			BNE		irq_2
			BL		PTIMER_ISR
			B		exit_irq
			
irq_2:		CMP		R5, #72					// check if interrupted by interval timer
			BNE		irq_3
			BL		ITIMER_ISR
			B		exit_irq
			
irq_3:		CMP		R5, #73					// check if interrupted by KEYs
			BNE		unexpected
			BL		KEY_ISR
			B		exit_irq
			
unexpected:	BNE		unexpected				// if not recognized, stop here
			
exit_irq:	STR		R5, [R4, #0x10]			// write to the End of Interrupt Register (ICCEOIR) to clear interrupt
			POP		{R0-R12, LR}
			SUBS	PC, LR, #4				// return from exception

//		B.2 UNDEFINED
SERVICE_UND:
			B		SERVICE_UND
		
//		B.3 SUPERVISOR		
SERVICE_SVC:
			B		SERVICE_SVC
		
//		B.4 ABT DATA		
SERVICE_ABT_DATA:
			B		SERVICE_ABT_DATA
	
//		B.5 ABT INST	
SERVICE_ABT_INST:
			B		SERVICE_ABT_INST
	
//		B.6 FIQ	
SERVICE_FIQ:
			B		SERVICE_FIQ
			
			
			
/* C. Configure Interrupt Service Routine */

/* 		
		C.1 Private Timer: increment timer if RUN_P=1
			- R3: private timer base address
			- R4: RUN_P value
			- R5: TIME value
			- R6: miscellaneous
*/
PTIMER_ISR:	PUSH	{R0-R12}
			LDR		R3, =PTIMER_ADDR		// private timer base address
			LDR		R4, RUN_P
			LDR		R5, TIME
			MOV		R6, #1					// reset private timer and clear interrupt
			STR		R6, [R3, #0xC]
			CMP		R4, #1					// if RUN_P is 1, increment TIME; if not, return
			BNE		itimer_end
			ADD		R5, #1
			STR		R5, TIME
ptimer_end: POP		{R0-R12}
			BX		LR

/* 		
		C.2 Interval Timer: increment COUNT if RUN_I=1
			- R3: interval timer base address
			- R4: RUN_I value
			- R5: COUNT value
			- R6: miscellaneous
*/
ITIMER_ISR:	PUSH	{R0-R12}
			LDR		R3, =ITIMER_ADDR		// interval timer base address
			LDR		R4, RUN_I
			LDR		R5, COUNT
			MOV		R6, #0					// reset interval timer and clear interrupt
			STR		R6, [R3]
			CMP		R4, #1					// if RUN_I is 1, increment COUNT; if not, return
			BNE		itimer_end
			ADD		R5, #1
			STR		R5, COUNT
itimer_end: POP		{R0-R12}
			BX		LR

/* 		
		C.3 Pushbutton: toggle RUN_I value
			- R3: interval tiemr base address
			- R4: KEY base address
			- R5: interval timer count value
			- R6: KEY value
			- R7: RUN_I value
			- R8: miscellaneous
*/
KEY_ISR:	PUSH	{R0-R12}
			LDR		R3, =ITIMER_ADDR
			LDR		R4, =KEY_ADDR
			LDR		R5, [R3, #0xC]			// load interval timer count value
			LSL		R5, R5, #16
			LDR		R8, [R3, #0x8]
			ADD		R5, R5, R8
			LDR		R6, [R4, #0xC]			// read edge capture register
			STR		R6, [R4, #0xC]			// clear the interrupt
			
key0:		CMP		R6, #0b0001				// check for KEY0: toggle RUN_I
			BNE		key1
			LDR		R7, RUN_I				// toggle RUN_I value
			CMP		R7, #0
			MOVEQ	R8, #1
			STREQ	R8, RUN_I
			BEQ		key_isr_end
			MOV		R8, #0
			STR		R8, RUN_I
			B		key_isr_end
			
key1:		CMP		R6, #0b0010				// check for KEY1: double interval counter start value
			BNE		key2
			LSL		R5, R5, #1				// double interval counter start value
			B		key_itimer_reset
			
key2: 		CMP		R6, #0b0100				// check for KEY1: double interval counter start value
			BNE		key3
			LSR		R5, R5, #1				// half interval counter start value
			B		key_itimer_reset
			
key3: 		CMP		R6, #0b1000				// check for KEY1: double interval counter start value
			BNE		key_isr_end
			LDR		R7, RUN_P				// toggle RUN_P value
			CMP		R7, #0
			MOVEQ	R8, #1
			STREQ	R8, RUN_P
			BEQ		key_isr_end
			MOV		R8, #0
			STR		R8, RUN_P
			B		key_isr_end
			
key_itimer_reset:
			MOV		R8, #0b1011				// stop interval timer
			STR		R8, [R3, #0x4]
			STR		R5, [R3, #0x8]			// store modified counter start value
			LSR		R8, R5, #16
			STR		R8, [R3, #0xC]
			MOV		R8, #0b0				// reset interval timer
			STR		R8, [R3]
			MOV		R8, #0b0111				// start interval timer
			STR		R8, [R3, #0x4]

key_isr_end:
			POP		{R0-R12}
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
			.skip	2
			
/* Global variables */
			.global	COUNT                           
COUNT:		.word	0x0						// used by timer
			.global	RUN_I					// used by pushbutton KEYs for interval timer
RUN_I:		.word	0x1						// initial value to increment COUNT
			.global TIME
TIME:		.word	0x0						// used for real-time clock
			.global	RUN_P					// used by pushbutton KEYs for private timer
RUN_P:		.word	0x1						// initial value to increment COUNT
			.global HEX_code
HEX_code:	.word	0x0						// used for 7-segment displays
			
			.end
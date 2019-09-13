/* 	
	Main program that counts on LEDs with toggle mode and speed adjustments by pushbuttons
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
			.equ	ITIMER_ADDR, 0xFF202000	// interval timer base mem address
			.equ	KEY_ADDR, 0xFF200050	// pushbutton KEYs base mem address
			.equ	LEDR_ADDR, 0xFF200000	// LEDR base mem address

			
			
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
			BL		CONFIG_ITIMER			// configure the Interval Timer
			BL		CONFIG_KEYS				// configure the pushbutton KEYs port

// 3) Enable IRQ interrupts in the ARM processor
			MOV		R0, #0b01010011			// enable IRQ, MODE = SVC
			MSR		CPSR, R0

// 4) Continously show value of COUNT in LEDs
LOOP:		LDR		R3, =LEDR_ADDR
			LDR		R4, COUNT				// global variable
			STR		R4, [R3]				// write to the LEDR lights
			B		LOOP



/* A. Configure Hardware */
//		A.1 Configure GIC
CONFIG_GIC:	LDR		R0, =ICDISER_ADDR		// ICDISERn: set enable register
			LDR		R1, =0x00000300			// set interrupt enable for: interval timer (ID=72), KEYs (ID=73)
			STR		R1, [R0, #0x8]
			LDR		R0, =ICDIPTR_ADDR		// ICDIPTRn: processor targets register
			LDR		R1, =0x00000101			// set cpu0 for: interval timer (ID=72), KEYs (ID=73)
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

//		A.2 Configure the Interval Timer
CONFIG_ITIMER:
			LDR		R0, =ITIMER_ADDR		// interval timer key base address
			LDR		R1, =0x017D7840			// store 50M of count for 0.25 seconds
			STR		R1, [R0, #0x8]			// store LSB of counter start value
			LSR		R1, R1, #16
			STR		R1, [R0, #0xC]			// store MSB of counter start value		
			LDR		R1, =0b0111				// enable interval timer with interrupt
			STR		R1, [R0, #0x4]			// interrupt mask register (base + 8)
			BX		LR
			
//		A.3 Configure KEY pushbuttons
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
irq_1:		CMP		R5, #72					// check if interrupted by interval timer
			BNE		irq_2
			BL		ITIMER_ISR
			B		exit_irq
irq_2:		CMP		R5, #73					// check if interrupted by KEYs
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
		C.1 Interval Timer: increment COUNT if RUN=1
			- R3: interval timer base address
			- R4: RUN value
			- R5: COUNT value
			- R6: miscellaneous
*/
ITIMER_ISR:	PUSH	{R0-R12}
			LDR		R3, =ITIMER_ADDR		// interval timer base address
			LDR		R4, RUN
			LDR		R5, COUNT
			MOV		R6, #0					// reset interval timer and clear interrupt
			STR		R6, [R3]
			CMP		R4, #1					// if RUN is 1, increment COUNT; if not, return
			BNE		itimer_end
			ADD		R5, #1
			STR		R5, COUNT
itimer_end: POP		{R0-R12}
			BX		LR

/* 		
		C.2 Pushbutton: toggle RUN value
			- R3: interval tiemr base address
			- R4: KEY base address
			- R5: interval timer count value
			- R6: KEY value
			- R7: RUN value
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
			
key0:		CMP		R6, #0b0001				// check for KEY0: toggle RUN
			BNE		key1
			LDR		R7, RUN					// toggle RUN value
			CMP		R7, #0
			MOVEQ	R8, #1
			STREQ	R8, RUN
			BEQ		key_isr_end
			MOV		R8, #0
			STR		R8, RUN
			B		key_isr_end
			
key1:		CMP		R6, #0b0010				// check for KEY1: double interval counter start value
			BNE		key2
			LSL		R5, R5, #1				// double interval counter start value
			B		key_itimer_reset
			
key2: 		CMP		R6, #0b0100				// check for KEY1: double interval counter start value
			BNE		key_isr_end
			LSR		R5, R5, #1				// half interval counter start value
			B		key_itimer_reset
			
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
			
			
			
/* Global variables */
			.global	COUNT                           
COUNT:		.word	0x0						// used by timer
			.global	RUN						// used by pushbutton KEYs
RUN:		.word	0x1						// initial value to increment COUNT
			
			.end
/* 	
	Main program that shows HEX digits when interrupted by pushbuttons
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
			
_start:
// 1) Set up stack pointers for IRQ and SVC processor modes
			MOV		R1, #0b11010010			// IRQ mode: interrupts disabled
			MSR		CPSR, R1				// write to CPSR
			LDR		SP, =0xFFFFFFFC			// set IRQ stack pointer
			MOV		R1, #0b11010011			// SVC mode: interrupts disabled
			MSR		CPSR, R1				// write to CPSR
			LDR		SP, =0x3FFFFFFC			// set SVC stack pointer
			
			BL		CONFIG_GIC				// configure the ARM generic interrupt controller
			
// 2) Configure the KEY pushbuttons port to generate interrupts
			LDR		R0, =0xFF200050			// pushbutton key base address
			MOV		R1, #0xF				// enable itnerupts for all 4 KEYs
			STR		R1, [R0, #0x8]			// interrupt mask register (base + 8)

// 3) Enable IRQ interrupts in the ARM processor
			MOV		R0, #0b01010011			// enable IRQ, MODE = SVC
			MSR		CPSR, R0

IDLE:		B		IDLE					// main program simply idles



/* A. Configure GIC */
CONFIG_GIC:	LDR		R0, =0xFFFED848			// ICDIPTRn: processor targets register
			LDR		R1, =0x00000100			// set target to cpu0
			STR		R1, [R0]
			LDR		R0, =0xFFFED108			// ICDISERn: set enable register
			LDR		R1, =0x00000200			// set interrupt enable
			STR		R1, [R0]
			MOV		R1, #0x1				// Enable ICDDCR to allow interrupts to be forwarded to CPU interface
			LDR		R0, =0xFFFED000
			STR		R1, [R0]
			LDR		R0, =0xFFFEC100			// enable interrupts of all priorities in CPU interface
			LDR		R1, =0xFF
			STR		R1, [R0, #4]
			MOV		R1, #0x1				// enable ICCICR to allow interrupts to be forwarded to CPU
			STR		R1, [R0]
			BX		LR



/* B. Define the exception service routines */
//		B.1 IRQ
SERVICE_IRQ:
			PUSH	{R0-R12, LR}
			LDR		R4, =0XFFFEC100			// GIC CPU interface base address
			LDR		R5, [R4, #0x0C]			// read the ICCIAR in the CPU interface
				
FPGA_IRQ1_HANDLER:
			CMP		R5, #73					// check the interrupt ID
			
UNEXPECTED:	BNE		UNEXPECTED				// if not recognized, stop here
			BL		KEY_ISR
			
EXIT_IRQ:	STR		R5, [R4, #0x10]			// write to the End of Interrupt Register (ICCEOIR)
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
		C.1 Pushbutton 
			- R0: KEY address
			- R1: HEX address
			- R2: previous KEY pointer
			- R3: current KEY state
			- R4: previous KEY state
			- R5: to be stored KEY state
			- R6: HEX data
			- R7: miscellaneous
*/
KEY_ISR:	PUSH	{R0-R12}
			LDR		R0, =0xFF200050			// base address of pushbutton KEYs
			LDR		R1, =0xFF200020			// base address of HEX display
			LDR		R2, =key_prev_state		// key_prev_state tracks previous state of keys
			LDR		R3, [R0, #0xC]			// read edge capture register
			STR		R3, [R0, #0xC]			// clear the interrupt
			LDR		R4, [R2]				// read old value
			EOR		R5, R3, R4				// toggle the bits
			STR		R5, [R2]				// write to key_prev_state for tracking
			MOV		R6, #0					// blank the HEX displays by default
			
check_key0:	MOV		R7, #0b0001
			ANDS	R7, R7, R5				// check for KEY0
			BEQ		check_key1				// if not KEY 0 then check key 1
			MOV		R6, #0b00111111			// display "0" on HEX0
			
check_key1: MOV		R7, #0b0010
			ANDS	R7, R7, R5				// check for KEY1
			BEQ		check_key2				// if not KEY1, then check KEY2
			MOV		R7, #0b00000110			// display "1" on HEX1
			ORR		R6, R6, R7, LSL #8		// shift such to display on HEX1
			
check_key2: MOV		R7, #0b0100				// check if KEY2 is pushed
			ANDS	R7, R7, R5				// check for KEY2
			BEQ		check_key3				// if not KEY2 then check KEY3
			MOV		R7, #0b01011011			// display "2" on HEX2
			ORR		R6, R6, R7, LSL #16		// shift such to display on HEX2
			
check_key3:	MOV		R7, #0b1000
			ANDS	R7, R7, R5				// check for KEY3
			BEQ		end_key_isr				// if not KEY3 then return
			MOV		R7, #0b01001111			// display "3" on HEX3
			ORR		R6, R6, R7, LSL #24		// shift such to display on HEX3
			
end_key_isr:
			STR		R6, [R1]
			POP		{R0-R12}
			BX		LR
			
key_prev_state:
			.word	0b0000					// for storing old KEY value
			
			.end
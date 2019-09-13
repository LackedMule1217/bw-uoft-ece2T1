# File Name: proc
# Author: Shi Jie (Barney) Wei
# Date: 01/15/19
#
#
# INPUT
# 	A. DIN[8:0]
#	B. Resetn
#	C. Clock
#	D. Run
# OUTPUT
#	A. Done
#	B. BusWires[8:0]

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog proc.v

# load simulation using mux as the top level simulation module
vsim proc

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# 1) Enable clock and reset
force Clock 0 0ns, 1 5ns -r 10ns
force Resetn 0 0ns, 1 10ns

# 2) Instructions:
#    		Instruction Table
#			000: mv       rX, rY	: rX <- rY
#			001: mvi      rX 	   : rX <- #D
#			010: add      rX, rY	: rX <- rX + rY
#			011: sub      rX, rY	: rX <- rX - rY
#			OPCODE format: III XXX YYY, where 
#			III = instruction, XXX = rX, and YYY = rY. For mvi,
#			a second word of data is loaded from DIN
#	  2.1) mvi
#	  		 2.1.1) mvi R0, 0
force DIN 2#001000000 10ns
force Run 1 20ns
force DIN 2#000000000 20ns
force Run 0 30ns
#	  		 2.1.2) mvi R1, 1
force DIN 2#001001000 40ns
force Run 1 50ns
force DIN 2#000000001 60ns
force Run 0 60ns
#	  		 2.1.3) mvi R2, 2
force DIN 2#001010000 70ns
force Run 1 80ns
force DIN 2#000000010 90ns
force Run 0 90ns
#	  		 2.1.4) mvi R3, 3
force DIN 2#001011000 100ns
force Run 1 110ns
force DIN 2#000000011 120ns
force Run 0 120ns
#	  		 2.1.5) mvi R4, 4
force DIN 2#001100000 130ns
force Run 1 140ns
force DIN 2#000000100 150ns
force Run 0 150ns
#	  		 2.1.6) mvi R5, 5
force DIN 2#001101000 160ns
force Run 1 170ns
force DIN 2#000000101 180ns
force Run 0 180ns
#	  		 2.1.7) mvi R6, 6
force DIN 2#001110000 190ns
force Run 1 200ns
force DIN 2#000000110 210ns
force Run 0 210ns
#	  		 2.1.8) mvi R7, 7
force DIN 2#001111000 220ns
force Run 1 230ns
force DIN 2#000000111 240ns
force Run 0 240ns
#	  2.2) mv R0, R1
force DIN 2#000000001 250ns
force Run 1 260ns
force Run 0 270ns
#	  2.3) add R2, R3
force DIN 2#010010011 280ns
force Run 1 290ns
force Run 0 300ns
#	  2.4) sub R5, R4
force DIN 2#011101100 330ns
force Run 1 340ns
force Run 0 350ns

run 380ns
# File Name: restoringDivider (4-Bit)
# Author: Shi Jie (Barney) Wei
# Date: October 30, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple veril
vlog restoringDivider.v

#load simulation using mux as the top level simulation module
vsim restoringDivider

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# INPUT
# 	A. KEY
#		A.1  KEY[0]			Active high synchronous reset
#		A.2 ~KEY[1]			Load (Go)
#	B. SW
#		B.1 	SW[3:0]		Divisor Value
#		B.2	SW[7:4]		Dividend Value
#	C. CLOCK
#		C.1 	CLOCK_50		Input Clock
# OUTPUT
#	A. LEDR
#		A.1	LEDR[3:0]	Quotient Value
#	B. HEX
#		B.1	HEX0			Divisor Value
#		B.2	HEX2			Dividend Value
#		B.3	HEX4			Quotiant Value
#		B.4	HEX5			Remainder Value
#		B.5	HEX[1|3]		0 Value
#	C. data_result
#		C.1 data_result[3:0]		Dividend Value -> Quotiant
#		C.2 data_result[8:4]		Register A -> Remainder


# TRIAL
#	A Trial 1
#		Input:
#			SW[7:4] = 4'b0111 (7)
#			SW[3:0] = 4'b0011 (3)
#		Output
#			data_result[8:4] = 5'b0_0001 (1)
#			data_result[3:0] = 4'b0010 (2)
#		A.1 Clock
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
#		A.2 Reset
force {KEY[0]} 1 0ns, 0 {10ns}
force {KEY[1]} 1 0ns
force {SW[7]} 0 0ns
force {SW[6]} 0 0ns
force {SW[5]} 0 0ns
force {SW[4]} 0 0ns
force {SW[3]} 0 0ns
force {SW[2]} 0 0ns
force {SW[1]} 0 0ns
force {SW[0]} 0 0ns
#		A.3.1 Input
#			SW[7:4] = 4'b0111 (7)
force {SW[7]} 0 10ns
force {SW[6]} 1 10ns
force {SW[5]} 1 10ns
force {SW[4]} 1 10ns
#			SW[3:0] = 4'b0100 (3)
force {SW[3]} 0 10ns
force {SW[2]} 0 10ns
force {SW[1]} 1 10ns
force {SW[0]} 1 10ns
force {KEY[1]} 0 20ns, 1 30ns
run 40ns
#		A.4 Run Simulation
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
force {KEY[1]} 0 0ns, 1 {10ns}
run 200ns



#	B Trial 2
#		Input:
#			SW[7:4] = 4'b1111 (15)
#			SW[3:0] = 4'b0100 (4)
#		Output
#			data_result[8:4] = 5'b0_0011 (3)
#			data_result[3:0] = 4'b0011 (3)
#		B.1 Clock
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
#		B.2 Reset
force {KEY[0]} 1 0ns, 0 {10ns}
force {KEY[1]} 1 0ns
force {SW[7]} 0 0ns
force {SW[6]} 0 0ns
force {SW[5]} 0 0ns
force {SW[4]} 0 0ns
force {SW[3]} 0 0ns
force {SW[2]} 0 0ns
force {SW[1]} 0 0ns
force {SW[0]} 0 0ns
#		B.3.1 Input
#			SW[7:4] = 4'b1111 (15)
force {SW[7]} 1 10ns
force {SW[6]} 1 10ns
force {SW[5]} 1 10ns
force {SW[4]} 1 10ns
#			SW[3:0] = 4'b0100 (4)
force {SW[3]} 0 10ns
force {SW[2]} 1 10ns
force {SW[1]} 0 10ns
force {SW[0]} 0 10ns
force {KEY[1]} 0 20ns, 1 30ns
run 40ns
#		B.4 Run Simulation
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
force {KEY[1]} 0 0ns, 1 {10ns}
run 200ns

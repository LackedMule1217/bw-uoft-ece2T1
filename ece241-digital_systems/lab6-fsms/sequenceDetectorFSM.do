# File Name: sequenceDetectorFSM
# Author: Shi Jie (Barney) Wei
# Date: October 26, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog sequenceDetectorFSM.v

#load simulation using mux as the top level simulation module
vsim sequenceDetectorFSM

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# INPUT
# 	A. KEY
#		A.1 ~KEY[0]			Clock
#	B. SW
#		B.1 	SW[0]			Asynchronous Active Low Reset
#		B.2	SW[1]			Input Signal
# OUTPUT
#	A. LEDR
#		A.1	LEDR[9:0]	Output signal


# TRIAL
#	A.1 Trial 1 (input: 1101_101_101_001101 -> output:0001_001_001_000001)
#		1) Clock
force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns
#		2) Reset
force {SW[0]} 0 0ns, 1 {10ns}
force {SW[1]} 0 0ns
#		3) Input Signal
force {SW[1]} 1 10ns, 0 30ns, 1 40ns
force {SW[1]} 1 50ns, 0 60ns, 1 70ns
force {SW[1]} 1 80ns, 0 90ns, 1 100ns
force {SW[1]} 0 110ns, 1 130ns, 0 150ns, 1 160ns
#		4) Run Simulation
run 180ns

#	A.2 Trial 2 (input: 1111_1_1_01110_1111 -> output:0001_1_1_01000_0001)
#		1) Clock
force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns
#		2) Reset
force {SW[0]} 0 0ns, 1 {10ns}
force {SW[1]} 0 0ns
#		3) Input Signal
force {SW[1]} 1 10ns
force {SW[1]} 1 50ns
force {SW[1]} 1 60ns
force {SW[1]} 0 70ns, 1 80ns, 0 110ns
force {SW[1]} 1 120ns
#		4) Run Simulation
run 170ns

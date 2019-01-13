# File Name: polyFunction2 - Ax + Bx^2 + C
# Author: Shi Jie (Barney) Wei
# Date: October 27, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple veril
vlog polyFunction2.v

#load simulation using mux as the top level simulation module
vsim polyFunction2

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# INPUT
# 	A. KEY
#		A.1  KEY[0]			Active low synchronous reset
#		A.2 ~KEY[1]			Load (Go)
#	B. SW
#		B.1 	SW[7:0]		Input Signal
#	C. CLOCK
#		C.1 	CLOCK_50		Input Clock
# OUTPUT
#	A. LEDR
#		A.1	LEDR[7:0]	Output LEDR signal
#	B. HEX
#		B.1	HEX0			Output HEX0 signal
#		B.2	HEX1			Output HEX1 signal


# TRIAL
#	A Trial 1 (input: A:5_B:4_C:3_x:2 -> output:0_0_0_0_0_0_29)
#		A.1 Clock
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
#		A.2 Reset
force {KEY[0]} 0 0ns, 1 {10ns}
force {KEY[1]} 1 0ns
force {SW[7]} 0 0ns
force {SW[6]} 0 0ns
force {SW[5]} 0 0ns
force {SW[4]} 0 0ns
force {SW[3]} 0 0ns
force {SW[2]} 0 0ns
force {SW[1]} 0 0ns
force {SW[0]} 0 0ns
#		A.3.1 Input Signal 5
force {SW[7]} 0 10ns
force {SW[6]} 0 10ns
force {SW[5]} 0 10ns
force {SW[4]} 0 10ns
force {SW[3]} 0 10ns
force {SW[2]} 1 10ns
force {SW[1]} 0 10ns
force {SW[0]} 1 10ns
force {KEY[1]} 0 20ns, 1 30ns
#		A.3.2 Input Signal 4
force {SW[7]} 0 40ns
force {SW[6]} 0 40ns
force {SW[5]} 0 40ns
force {SW[4]} 0 40ns
force {SW[3]} 0 40ns
force {SW[2]} 1 40ns
force {SW[1]} 0 40ns
force {SW[0]} 0 40ns
force {KEY[1]} 0 50ns, 1 60ns
#		A.3.2 Input Signal 3
force {SW[7]} 0 70ns
force {SW[6]} 0 70ns
force {SW[5]} 0 70ns
force {SW[4]} 0 70ns
force {SW[3]} 0 70ns
force {SW[2]} 0 70ns
force {SW[1]} 1 70ns
force {SW[0]} 1 70ns
force {KEY[1]} 0 80ns, 1 90ns
#		A.3.2 Input Signal 2
force {SW[7]} 0 100ns
force {SW[6]} 0 100ns
force {SW[5]} 0 100ns
force {SW[4]} 0 100ns
force {SW[3]} 0 100ns
force {SW[2]} 0 100ns
force {SW[1]} 1 100ns
force {SW[0]} 0 100ns
force {KEY[1]} 0 110ns, 1 120ns
#		A.4 Run Simulation
run 190ns

#	B Trial 2 (input: A:15_B:4_C:29_x:2 -> output:0_0_0_0_0_0_75)
#		B.1 Clock
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
#		B.2 Reset
force {KEY[0]} 0 0ns, 1 {10ns}
force {KEY[1]} 1 0ns
force {SW[7]} 0 0ns
force {SW[6]} 0 0ns
force {SW[5]} 0 0ns
force {SW[4]} 0 0ns
force {SW[3]} 0 0ns
force {SW[2]} 0 0ns
force {SW[1]} 0 0ns
force {SW[0]} 0 0ns
#		B.3.1 Input Signal 5
force {SW[7]} 0 10ns
force {SW[6]} 0 10ns
force {SW[5]} 0 10ns
force {SW[4]} 0 10ns
force {SW[3]} 1 10ns
force {SW[2]} 1 10ns
force {SW[1]} 1 10ns
force {SW[0]} 1 10ns
force {KEY[1]} 0 20ns, 1 30ns
#		B.3.2 Input Signal 4
force {SW[7]} 0 40ns
force {SW[6]} 0 40ns
force {SW[5]} 0 40ns
force {SW[4]} 0 40ns
force {SW[3]} 0 40ns
force {SW[2]} 1 40ns
force {SW[1]} 0 40ns
force {SW[0]} 0 40ns
force {KEY[1]} 0 50ns, 1 60ns
#		B.3.2 Input Signal 3
force {SW[7]} 0 70ns
force {SW[6]} 0 70ns
force {SW[5]} 0 70ns
force {SW[4]} 1 70ns
force {SW[3]} 1 70ns
force {SW[2]} 1 70ns
force {SW[1]} 0 70ns
force {SW[0]} 1 70ns
force {KEY[1]} 0 80ns, 1 90ns
#		B.3.2 Input Signal 2
force {SW[7]} 0 100ns
force {SW[6]} 0 100ns
force {SW[5]} 0 100ns
force {SW[4]} 0 100ns
force {SW[3]} 0 100ns
force {SW[2]} 0 100ns
force {SW[1]} 1 100ns
force {SW[0]} 0 100ns
force {KEY[1]} 0 110ns, 1 120ns
#		B.4 Run Simulation
run 190ns
# File Name: polyFunction2 - Ax + Bx^2 + C
# Author: Shi Jie (Barney) Wei
# Date: October 27, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple veril
vlog polyFunction2.v

#load simulation using mux as the top level simulation module
vsim datapath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# INPUT
# 	A. INPUT
#		A.1  resetn			Active low synchronous reset
#		A.2  go				Load (Go)
#		A.3  clk				Input Clock
# OUTPUT
#	A. ld_a, ld_b, ld_c, ld_x, ld_r
#	B. ld_alu_out
#	C. [1:0]  alu_select_a, alu_select_b
#	D. alu_op


# TRIAL
#	A Trial 1 (input: A:5_B:4_C:3_x:2 -> output:0_0_0_0_0_0_29)
#		A.1 Clock
force {clk} 0 0ns, 1 {5ns} -r 10ns
#		A.2 Reset
force {resetn} 0 0ns, 1 {10ns}
force {go} 0 0ns, 1 {10ns} -r 20ns

#		A.4 Run Simulation
run 150ns
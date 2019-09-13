# File Name: main
# Author: Shi Jie (Barney) Wei
# Date: 01/16/19
#
#
# INPUT
# 	A. KEY
#		A.1  	KEY[0]		MClock
#		A.2  	KEY[1]		PClock
#	B. SW
#		B.1 	SW[0]			Resetn
#		B.2	SW[9]			Run
# OUTPUT
#	A. LEDR
#		A.1	LEDR[8:0]	Bus
#		A.2	LEDR[9]		Done

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v

# load simulation using mux as the top level simulation module
vsim -L altera_mf_ver main

# log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# 1) Enable MClock, PClock, and Resetn
force {KEY[0]} 0 0ps, 1 5ps
force {KEY[1]} 0 0ps, 1 5ps -r 10ps
force {SW[0]} 0 0ps, 1 10ps

# 2) Instructions from mif:
#	  2.1) mvi r0, 5
force {KEY[0]} 0 10ps, 1 15ps
force {SW[9]} 0 10ps, 1 20ps
force {KEY[0]} 0 20ps, 1 25ps
#	  2.2) mv  r0, r5
force {KEY[0]} 0 30ps, 1 35ps
force {SW[9]} 0 30ps, 1 40ps
#	  2.3) add r0, r1
force {KEY[0]} 0 40ps, 1 45ps
force {SW[9]} 0 40ps, 1 50ps
#	  2.4) sub r0, r0
force {KEY[0]} 0 80ps, 1 85ps
force {SW[9]} 0 80ps, 1 90ps, 0 100ps

# 3) Run:
run 140ps
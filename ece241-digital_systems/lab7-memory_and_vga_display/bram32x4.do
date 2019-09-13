# File Name: bram32x4
# Author: Shi Jie (Barney) Wei
# Date: October 31, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog bram32x4.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver bram32x4

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



# INPUT
# 	A. KEY
#		A.1  	KEY[0]		Input Clock
#	B. SW
#		B.1	SW[9]			Write Enable Input
#		B.2 	SW[8:4]		Address Input
#		B.3	SW[3:0]		Data Input
# OUTPUT
#	A. HEX
#		A.1	HEX[5:4]		Address
#		A.2	HEX2			Input Data
#		A.3	HEX0			Output Data
#	B. DATAOUT
#		B.1	data_out[3:0]

# Clock - Repeat
force {KEY[0]} 0 0ps, 1 {5ps} -r 10ps

# Data Input - Repeat
force {SW[0]} 0 0ps, 1 {10ps} -r 20ps
force {SW[1]} 0 0ps, 1 {20ps} -r 40ps
force {SW[2]} 0 0ps, 1 {40ps} -r 80ps
force {SW[3]} 0 0ps, 1 {80ps} -r 160ps

# Address Input - Repeat
force {SW[4]} 0 0ps, 1 {160ps} -r 320ps
force {SW[5]} 0 0ps, 1 {320ps} -r 640ps
force {SW[6]} 0 0ps, 1 {640ps} -r 1280ps
force {SW[7]} 0 0ps, 1 {1280ps} -r 2560ps
force {SW[8]} 0 0ps, 1 {2560ps} -r 5120ps

# Write Enable Input - Repeat
force {SW[9]} 0 0ps, 1 {7.5ps} -r 15ps

# Run Simulation
run 5120ps

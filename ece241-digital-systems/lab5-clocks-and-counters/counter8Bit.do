# File Name: counter8Bit
# Author: Shi Jie (Barney) Wei
# Date: October 17, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog counter8Bit.v

#load simulation using mux as the top level simulation module
vsim counter8Bit

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# Reset
force {SW[0]} 0 5ns, 1 {10ns}

run 10ns

# Clock test input
force {KEY[0]} 1 0ns, 0 {5ns} -r 10ns

# Enable test input
force {SW[1]} 0 0ns, 1 {10ns} -r 20ns


# run simulation for a few ns
run 5120ns
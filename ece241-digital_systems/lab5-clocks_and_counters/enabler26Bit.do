# File Name: enabler28Bit
# Author: Shi Jie (Barney) Wei
# Date: October 17, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog enabler26Bit.v

#load simulation using mux as the top level simulation module
vsim enabler26Bit

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# Reset
force {clearB} 0 5ns, 1 {10ns}

run 10ns

# Clock test input
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns

# Enable test input
force {SW[0]} 0 0ns, 1 {1000ns} -r 2000ns
force {SW[1]} 0 0ns, 1 {2000ns} -r 4000ns


# run simulation for a few ns
run 4000ns
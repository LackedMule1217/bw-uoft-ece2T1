# File Name: morseCodeEncoder8Bit
# Author: Shi Jie (Barney) Wei
# Date: October 19, 2018

# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog morseCodeEncoder8Bit.v

#load simulation using mux as the top level simulation module
vsim morseCodeEncoder8Bit

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# Reset
force {KEY[0]} 0 0ns, 1 {10ns}

run 20ns


# Clock test input
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns

# Enable test input
force {SW[0]} 0 0ns, 1 {400ns} -r 800ns
force {SW[1]} 0 0ns, 1 {800ns} -r 1600ns
force {SW[2]} 0 0ns, 1 {1600ns} -r 3200ns
force {KEY[1]} 1 0ns, 0 {20ns} -r 400ns
force {KEY[0]} 0 0ns, 1 {10ns} -r 400ns

# run simulation for a few ns
run 3200ns


# Reset
force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
force {KEY[0]} 0 10ns, 1 {20ns}

run 20ns

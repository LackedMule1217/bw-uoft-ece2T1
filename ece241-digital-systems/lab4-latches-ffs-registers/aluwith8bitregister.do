# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog aluwith8bitregister.v

#load simulation using mux as the top level simulation module
vsim aluwith8bitregister

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# clock test case
force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns

# data test case
force {SW[0]} 0 0ns, 1 {10ns} -r 20ns
force {SW[1]} 0 0ns, 1 {20ns} -r 40ns
force {SW[2]} 0 0ns, 1 {40ns} -r 80ns
force {SW[3]} 0 0ns, 1 {80ns} -r 160ns

# Reset_b test case
force {SW[9]} 0 0ns, 1 {160ns} -r 320ns

# key test case
force {KEY[1]} 0 0ns, 1 {320ns} -r 640ns
force {KEY[2]} 0 0ns, 1 {640ns} -r 1280ns
force {KEY[3]} 0 0ns, 1 {1280ns} -r 2560ns

#run simulation for a few ns
run 5120ns
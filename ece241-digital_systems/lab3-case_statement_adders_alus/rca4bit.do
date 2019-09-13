# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog rca4bit.v

#load simulation using mux as the top level simulation module
vsim rca4bit

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# value1 test case
force {SW[0]} 0 0ns, 1 {5ns} -r 10ns
force {SW[1]} 0 0ns, 1 {10ns} -r 20ns
force {SW[2]} 0 0ns, 1 {20ns} -r 40ns
force {SW[3]} 0 0ns, 1 {40ns} -r 80ns

# value2 test case
force {SW[4]} 0 0ns, 1 {80ns} -r 160ns
force {SW[5]} 0 0ns, 1 {160ns} -r 320ns
force {SW[6]} 0 0ns, 1 {320ns} -r 640ns
force {SW[7]} 0 0ns, 1 {640ns} -r 1280ns


#run simulation for a few ns
run 1280ns
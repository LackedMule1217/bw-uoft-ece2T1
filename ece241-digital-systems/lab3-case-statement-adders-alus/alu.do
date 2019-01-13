# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog alu.v

#load simulation using mux as the top level simulation module
vsim alu

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# key test case
force {KEY[0]} 0 0ns, 1 {5ns} -r 10ns
force {KEY[1]} 0 0ns, 1 {10ns} -r 20ns
force {KEY[2]} 0 0ns, 1 {20ns} -r 40ns

# value1 test case
force {SW[0]} 0 0ns, 1 {40ns} -r 80ns
force {SW[1]} 0 0ns, 1 {80ns} -r 160ns
force {SW[2]} 0 0ns, 1 {160ns} -r 320ns
force {SW[3]} 0 0ns, 1 {320ns} -r 640ns

# value2 test case
force {SW[4]} 0 0ns, 1 {640ns} -r 1280ns
force {SW[5]} 0 0ns, 1 {1280ns} -r 2560ns
force {SW[6]} 0 0ns, 1 {2560ns} -r 5120ns
force {SW[7]} 0 0ns, 1 {5120ns} -r 10240ns


#run simulation for a few ns
run 10 240ns